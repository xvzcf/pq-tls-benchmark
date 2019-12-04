#!/usr/bin/perl

use strict;
use warnings;

if ($#ARGV + 1 != 4) {
    print "\nUsage: ab_perf.pl server_ip n_connections n_concurent_connections time_limit_in_seconds\n";
    exit;
}

my $ab = '/home/cpaquin/httpd-2.4.41/support/ab';
my $certs = '/home/cpaquin/perf/nov27/certs';
my $server = $ARGV[0];
my $connections = $ARGV[1];
my $concurent = $ARGV[2];
my $timelimit = $ARGV[3];

my @kex_algs = ('P-256', 'bike1l1cpa', 'frodo640aes', 'kyber512_90s', 'newhope512cca', 'ntru_hps2048509', 'lightsaber', 'sikep434', 
		'p256-bike1l1cpa', 'p256-frodo640aes', 'p256-kyber512_90s', 'p256-newhope512cca', 'p256-ntru_hps2048509', 'p256-lightsaber', 'p256-sikep434');

my @files = ('index1k.html', 'index10k.html', 'index100k.html', 'index1M.html');

foreach my $kex_alg (@kex_algs) {
    foreach my $file (@files) {
	my $sig_alg = 'ecdsap256';
	my $port = '4433';
	my $output = 'ab-kex-L1-' . $kex_alg . '-' . $sig_alg . '-' . $file;
	my $cmd = "$ab -q -e $output.csv -c $concurent -t $timelimit -f TLS1.3 -F $kex_alg -W $certs/ecdsap256_CA.crt https://$server:$port/$file";
#	my $cmd = "$ab -q -e $output.csv -n $connections -c $concurent -f TLS1.3 -F $kex_alg -W $certs/ecdsap256_CA.crt https://$server:$port/$file";
	system("echo $cmd");
	system($cmd . "> $output.txt");
    }
}
