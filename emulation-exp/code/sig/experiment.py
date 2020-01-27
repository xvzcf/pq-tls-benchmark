import csv
from multiprocessing import Pool
import os
import subprocess
import sys

# Our experiment used POOL_SIZE = 40
POOL_SIZE = 4

MEASUREMENTS_PER_TIMER = 1
TIMERS = 4

def run_subprocess(command, working_dir='.', expected_returncode=0):
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=working_dir
    )
    if(result.stderr):
        print(result.stderr)
    assert result.returncode == expected_returncode
    return result.stdout.decode('utf-8')

def change_qdisc(ns, dev, pkt_loss, delay):
    if pkt_loss == 0:
        command = [
            'ip', 'netns', 'exec', ns,
            'tc', 'qdisc', 'change',
            'dev', dev, 'root', 'netem',
            'limit', '1000',
            'delay', delay,
            'rate', '1000mbit'
        ]
    else:
        command = [
            'ip', 'netns', 'exec', ns,
            'tc', 'qdisc', 'change',
            'dev', dev, 'root', 'netem',
            'limit', '1000',
            'loss', '{0}%'.format(pkt_loss),
            'delay', delay,
            'rate', '1000mbit'
        ]

    print(" > " + " ".join(command))
    run_subprocess(command)

def time_handshake(sig_alg, measurements):
    command = [
        'ip', 'netns', 'exec', 'cli_ns',
         './s_timer.o', sig_alg, str(measurements)
    ]
    print(" > " + " ".join(command))
    result = run_subprocess(command)
    return [float(i) for i in result.strip().split(',')]

def run_timers(sig_alg, timer_pool):
    results_nested = timer_pool.starmap(time_handshake, [(sig_alg, MEASUREMENTS_PER_TIMER)] * TIMERS)
    return [item for sublist in results_nested for item in sublist]

def get_rtt_ms():
    command = [
        'ip', 'netns', 'exec', 'cli_ns',
        'ping', '10.0.0.1', '-c', '30'
    ]

    print(" > " + " ".join(command))
    result = run_subprocess(command)

    result_fmt = result.splitlines()[-1].split("/")
    return result_fmt[4].replace(".", "p")

# Main
timer_pool = Pool(processes=POOL_SIZE)

if not os.path.exists('data'):
    os.makedirs('data')

sig_alg = sys.argv[1]

for latency_ms in ['2.684ms', '15.458ms', '39.224ms', '97.73ms']:
    # To get actual (emulated) RTT
    change_qdisc('cli_ns', 'cli_ve', 0, delay=latency_ms)
    change_qdisc('srv_ns', 'srv_ve', 0, delay=latency_ms)
    rtt_str = get_rtt_ms()

    with open('data/{}_{}ms.csv'.format(sig_alg, rtt_str),'w') as out:
        csv_out=csv.writer(out)
        for pkt_loss in [0, 0.1, 0.5, 1, 1.5, 2, 2.5, 3]:
            change_qdisc('cli_ns', 'cli_ve', pkt_loss, delay=latency_ms)
            change_qdisc('srv_ns', 'srv_ve', pkt_loss, delay=latency_ms)
            result = run_timers(sig_alg, timer_pool)
            result.insert(0, pkt_loss)
            csv_out.writerow(result)

        for pkt_loss in range(4, 21):
            change_qdisc('cli_ns', 'cli_ve', pkt_loss, delay=latency_ms)
            change_qdisc('srv_ns', 'srv_ve', pkt_loss, delay=latency_ms)
            result = run_timers(sig_alg, timer_pool)
            result.insert(0, pkt_loss)
            csv_out.writerow(result)

timer_pool.close()
timer_pool.join()
