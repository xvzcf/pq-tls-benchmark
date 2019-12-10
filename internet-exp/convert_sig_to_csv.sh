#!/bin/bash

sig_algs=(ecdsap256 rsa3072 dilithium2 picnicl1fs picnic2l1fs qteslapi)
ec_hybrid_sig_algs=(p256_dilithium2 p256_picnicl1fs p256_picnic2l1fs p256_qteslapi)
rsa_hybrid_sig_algs=(rsa3072_dilithium2 rsa3072_picnicl1fs rsa3072_picnic2l1fs rsa3072_qteslapi)
echo sig_alg,1k,10k,100k,1M
for i in ${sig_algs[@]}
do
    ms1k=$(grep $i ab_sig_sed.out | grep -v "p256_" | grep -v "rsa3072_" | grep 1k | sed -E "s/.*,.*,(.*)/\1/")
    ms10k=$(grep $i ab_sig_sed.out | grep -v "p256_" | grep -v "rsa3072_" | grep 10k | sed -E "s/.*,.*,(.*)/\1/")
    ms100k=$(grep $i ab_sig_sed.out | grep -v "p256_" | grep -v "rsa3072_" | grep 100k | sed -E "s/.*,.*,(.*)/\1/")
    ms1M=$(grep $i ab_sig_sed.out | grep -v "p256_" | grep -v "rsa3072_" | grep 1M | sed -E "s/.*,.*,(.*)/\1/")
    echo $i,$ms1k,$ms10k,$ms100k,$ms1M
done
for i in ${ec_hybrid_sig_algs[@]}
do
    ms1k=$(grep $i ab_sig_sed.out | grep 1k | sed -E "s/.*,.*,(.*)/\1/")
    ms10k=$(grep $i ab_sig_sed.out | grep 10k | sed -E "s/.*,.*,(.*)/\1/")
    ms100k=$(grep $i ab_sig_sed.out | grep 100k | sed -E "s/.*,.*,(.*)/\1/")
    ms1M=$(grep $i ab_sig_sed.out | grep 1M | sed -E "s/.*,.*,(.*)/\1/")
    echo $i,$ms1k,$ms10k,$ms100k,$ms1M
done
for i in ${rsa_hybrid_sig_algs[@]}
do
    ms1k=$(grep $i ab_sig_sed.out | grep 1k | sed -E "s/.*,.*,(.*)/\1/")
    ms10k=$(grep $i ab_sig_sed.out | grep 10k | sed -E "s/.*,.*,(.*)/\1/")
    ms100k=$(grep $i ab_sig_sed.out | grep 100k | sed -E "s/.*,.*,(.*)/\1/")
    ms1M=$(grep $i ab_sig_sed.out | grep 1M | sed -E "s/.*,.*,(.*)/\1/")
    echo $i,$ms1k,$ms10k,$ms100k,$ms1M
done

