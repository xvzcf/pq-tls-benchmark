#!/bin/bash

kex_algs=(P-256 bike1l1cpa frodo640aes kyber512_90s newhope512cca ntru_hps2048509 lightsaber sikep434)
hybrid_kex_algs=(p256-bike1l1cpa p256-frodo640aes p256-kyber512_90s p256-newhope512cca p256-ntru_hps2048509 p256-lightsaber p256-sikep434)
echo kex_alg,1k,10k,100k,1M
for i in ${kex_algs[@]}
do
    ms1k=$(grep $i ab_kex_sed.out | grep -v "p256\-" | grep 1k | sed -E "s/.*,.*,(.*)/\1/")
    ms10k=$(grep $i ab_kex_sed.out | grep -v "p256\-" | grep 10k | sed -E "s/.*,.*,(.*)/\1/")
    ms100k=$(grep $i ab_kex_sed.out | grep -v "p256\-" | grep 100k | sed -E "s/.*,.*,(.*)/\1/")
    ms1M=$(grep $i ab_kex_sed.out | grep -v "p256\-" | grep 1M | sed -E "s/.*,.*,(.*)/\1/")
    echo $i,$ms1k,$ms10k,$ms100k,$ms1M
done
for i in ${hybrid_kex_algs[@]}
do
    ms1k=$(grep $i ab_kex_sed.out | grep 1k | sed -E "s/.*,.*,(.*)/\1/")
    ms10k=$(grep $i ab_kex_sed.out | grep 10k | sed -E "s/.*,.*,(.*)/\1/")
    ms100k=$(grep $i ab_kex_sed.out | grep 100k | sed -E "s/.*,.*,(.*)/\1/")
    ms1M=$(grep $i ab_kex_sed.out | grep 1M | sed -E "s/.*,.*,(.*)/\1/")
    echo $i,$ms1k,$ms10k,$ms100k,$ms1M
done

