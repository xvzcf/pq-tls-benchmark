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

my @sig_algs = ( 'ecdsap256', 'rsa3072', 'dilithium2', 'picnicl1fs', 'picnic2l1fs', 'qteslapi', 'p256_dilithium2', 'p256_picnicl1fs', 'p256_picnic2l1fs', 'p256_qteslapi', 'rsa3072_dilithium2', 'rsa3072_picnicl1fs', 'rsa3072_picnic2l1fs', 'rsa3072_qteslapi');

my %ports = (
    'ecdsap256' => '4433',
    'rsa3072'   => '4434',
    'dilithium2' => '4435',
    'picnicl1fs' => '4436',
    'picnic2l1fs' => '4444',
    'qteslapi' => '4437',
    'p256_dilithium2' => '4438',
    'p256_picnicl1fs' => '4439',
    'p256_picnic2l1fs' => '4445',
    'p256_qteslapi' => '4440',
    'rsa3072_dilithium2' => '4441',
    'rsa3072_picnicl1fs' => '4442',
    'rsa3072_picnic2l1fs' => '4446',
    'rsa3072_qteslapi' => '4443',
);

my @files = ('index1k.html', 'index10k.html', 'index100k.html', 'index1M.html');

foreach my $sig_alg (@sig_algs) {
    foreach my $file (@files) {
	my $port = $ports{$sig_alg};
	my $cafile = $sig_alg . '_CA.crt';
	my $kex_alg = 'p256-kyber512_90s';
	my $output = 'ab-sig-L1-' . $kex_alg . '-' . $sig_alg . '-' . $file;
#	my $cmd = "$ab -d -c $concurent -t $timelimit -f TLS1.3 -F $kex_alg https://$server:$port/$file";
	my $cmd = "$ab -q -e $output.csv -c $concurent -t $timelimit -f TLS1.3 -F $kex_alg -W $certs/$cafile https://$server:$port/$file";
	system("echo $cmd");
	system($cmd . "> $output.txt");
    }
}
