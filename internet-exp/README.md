The internet experiments had the client connecting to each server (eastUS, centralUS, europe, australia), for each alg (kex/sig), for each page (1kB, 10kB, 100kB, 1MB), for 120 seconds.

The results are separated in the `east/`, `central/`, `europe/`, `australia/` folders. In each folder, the kex and sig experiments were launched as follows:
    - `perl ../ab_perf_kex.pl <server_ip> na 1 120 > <server>_kex.out &`
    - `perl ../ab_perf_sig.pl <server_ip> na 1 120 > <server>_sig.out &`

`ab_perf_[kex|sig].pl` uses a modified apache benchmarking (`ab`) tool (to support TLS 1.3, add PQC, add server cert validation), taken from [https://github.com/christianpaquin/httpd/tree/cp-enable-tls13-ab](https://github.com/christianpaquin/httpd/tree/cp-enable-tls13-ab) (and built using the optimized OQS-OpenSSL 1.1.1 fork). For archival purposes, the patch is included here in the `ab.c.2019-11-27.patch` file

The output files are in the corresponding VM folders. To extract data for comparison and plotting:

For KEX (replace "50" by "95" or as required):
 - extract the median value for each run: `grep "50%" ab-kex-L1-*.txt | sed -E "s/^ab-kex-L1-(.*)-ecdsap256-index(.*)\.html\.txt:  50%\s*(.*)/\1,\2,\3/" > ab_kex_sed_50.out`
 - merge mean values into one csv file: `../../convert_kex_to_csv.sh > ab_kex.csv`

For sig (replace "50" by "95" or as required):
 - extract the median value for each run: `grep "50%" ab-sig-L1-*.txt | sed -E "s/^ab-sig-L1-p256-kyber512_90s-(.*)-index(.*)\.html\.txt:  50%\s*(.*)/\1,\2,\3/" > ab_sig_sed_50.out`
 - merge mean values into one csv file: `../../convert_sig_to_csv.sh > ab_sig.csv`

To convert the data for latex-friendly plotting, use `prepare_plotdata.sh`.
