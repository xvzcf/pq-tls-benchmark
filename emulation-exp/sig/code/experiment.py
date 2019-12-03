import csv
from multiprocessing import Pool
import numpy as np
import os
import subprocess
import sys

def run_subprocess(command, working_dir='.', env=None, expected_returncode=0):
    """
    Helper function to run a shell command and report success/failure
    depending on the exit status of the shell command.
    """
    if env is not None:
        env_ = os.environ.copy()
        env_.update(env)
        env = env_

    # Note we need to capture stdout/stderr from the subprocess,
    # then print it, which nose/unittest will then capture and
    # buffer appropriately
    print(working_dir + " > " + " ".join(command))
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=working_dir,
        env=env,
    )
    #print(result.stdout.decode('utf-8'))
    print(result.stderr.decode('utf-8'))
    assert result.returncode == expected_returncode, \
        "Got unexpected return code {}".format(result.returncode)
    return result.stdout.decode('utf-8')

def change_qdisc(ns, dev, pkt_loss, delay, jitter='0ms', distribution='normal'):
    if pkt_loss == 0:
        run_subprocess(
            [
                'ip', 'netns', 'exec', ns,
                'tc', 'qdisc', 'change',
                'dev', dev, 'root', 'netem',
                'limit', '1000',
                'delay', delay, #jitter, 'distribution', distribution,
                'rate', '1000mbit'
            ])
    else:
        run_subprocess(
            [
                'ip', 'netns', 'exec', ns,
                'tc', 'qdisc', 'change',
                'dev', dev, 'root', 'netem',
                'limit', '1000',
                'loss', '{0}%'.format(pkt_loss),
                'delay', delay, #jitter, 'distribution', distribution,
                'rate', '1000mbit'
            ])

def handshake_timer(sig_alg, measurements):
    command = ['ip', 'netns', 'exec', 'cli_ns',
                './s_timer.o', sig_alg, str(measurements)]

    #print(" > " + " ".join(command))
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd='.')
    if(result.stderr):
        print(result.stderr)
    assert result.returncode == 0
    return [float(i) for i in result.stdout.decode('utf-8').strip().split(',')]

def run_timers(sig_alg, timer_pool):
    measurements = 30
    results_nested = timer_pool.starmap(handshake_timer, [(sig_alg, measurements)] * 50)
    results_flat = np.array(results_nested).flat

    min_val = np.amin(results_flat)
    pct_25 = np.percentile(results_flat, 25)
    median = np.median(results_flat)
    pct_95 = np.percentile(results_flat, 95)
    max_val = np.amax(results_flat)

    return (min_val, pct_25, median, pct_95, max_val)

def get_rtt_ms():
    command = ['ip', 'netns', 'exec', 'cli_ns',
                     'ping', '10.0.0.1', '-c', '30']
    print(" > " + " ".join(command))
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd='.')
    result_fmt = result.stdout.decode("utf-8").splitlines()[-1].split("/")
    return result_fmt[4].replace(".", "p")

# Main
timer_pool = Pool(processes=4)

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
        csv_out.writerow(['pktloss', 'min', '25pct', 'median', '95pct', 'max'])

        for pkt_loss in [0, 0.1, 0.5, 1, 1.5, 2, 2.5, 3]:
            change_qdisc('cli_ns', 'cli_ve', pkt_loss, delay=latency_ms)
            change_qdisc('srv_ns', 'srv_ve', pkt_loss, delay=latency_ms)
            result = run_timers(sig_alg, timer_pool)
            csv_out.writerow((pkt_loss, result[0], result[1], result[2], result[3], result[4]))

        for pkt_loss in range(4, 21):
            change_qdisc('cli_ns', 'cli_ve', pkt_loss, delay=latency_ms)
            change_qdisc('srv_ns', 'srv_ve', pkt_loss, delay=latency_ms)
            result = run_timers(sig_alg, timer_pool)
            csv_out.writerow((pkt_loss, result[0], result[1], result[2], result[3], result[4]))

timer_pool.close()
timer_pool.join()
