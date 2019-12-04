#!/bin/bash

percentiles=(50 95)
MVs=(east central europe australia)
page_sizes=(1k 10k 100k 1M)
kex_algs=(P-256 bike1l1cpa frodo640aes kyber512_90s newhope512cca ntru_hps2048509 lightsaber sikep434 p256-bike1l1cpa p256-frodo640aes p256-kyber512_90s p256-newhope512cca p256-ntru_hps2048509 p256-lightsaber p256-sikep434)
sig_algs=(ecdsap256 rsa3072 dilithium2 picnicl1fs picnic2l1fs qteslapi p256_dilithium2 p256_picnicl1fs p256_picnic2l1fs p256_qteslapi rsa3072_dilithium2 rsa3072_picnicl1fs rsa3072_picnic2l1fs rsa3072_qteslapi)
for perc in ${percentiles[@]}
do
    echo ------------
    echo $perc th percentile
    for kex_alg in ${kex_algs[@]}
    do
	echo creating $kex_alg-$perc.csv
	echo pagesizekb,east,central,europe,australia >> $kex_alg-$perc.csv
	num_page_size=1
	for page_size in ${page_sizes[@]}
	do
	    east=$(grep ^$kex_alg east/ab_kex_sed_$perc.out | grep $page_size | sed -E "s/.*,.*,(.*)/\1/")
	    central=$(grep ^$kex_alg central/ab_kex_sed_$perc.out | grep $page_size | sed -E "s/.*,.*,(.*)/\1/")
	    europe=$(grep ^$kex_alg europe/ab_kex_sed_$perc.out | grep $page_size | sed -E "s/.*,.*,(.*)/\1/")
	    australia=$(grep ^$kex_alg australia/ab_kex_sed_$perc.out | grep $page_size | sed -E "s/.*,.*,(.*)/\1/")
	    echo $num_page_size,$east,$central,$europe,$australia >> $kex_alg-$perc.csv
	    num_page_size=$((10*$num_page_size))
	done
    done
    for sig_alg in ${sig_algs[@]}
    do
	echo creating $sig_alg-$perc.csv
	echo pagesizekb,east,central,europe,australia >> $sig_alg-$perc.csv
	num_page_size=1
	for page_size in ${page_sizes[@]}
	do
	    east=$(grep ^$sig_alg east/ab_sig_sed_$perc.out | grep $page_size | sed -E "s/.*,.*,(.*)/\1/")
	    central=$(grep ^$sig_alg central/ab_sig_sed_$perc.out | grep $page_size | sed -E "s/.*,.*,(.*)/\1/")
	    europe=$(grep ^$sig_alg europe/ab_sig_sed_$perc.out | grep $page_size | sed -E "s/.*,.*,(.*)/\1/")
	    australia=$(grep ^$sig_alg australia/ab_sig_sed_$perc.out | grep $page_size | sed -E "s/.*,.*,(.*)/\1/")
	    echo $num_page_size,$east,$central,$europe,$australia >> $sig_alg-$perc.csv
	    num_page_size=$((10*$num_page_size))
	done
    done
done

