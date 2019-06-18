#!/usr/bin/env bash

export TMPDIR=~/tmp 
FILE=$(mktemp -p $TMPDIR)

while read f
do
  grep -E '(Status|LIMITS|LOCALLY_SOLVED)' $f >> $FILE
done < <(find -name result-\*.tsv)

sort -k3 -k4 -k5 -k6 -k7 -k8 -k9 -k10 -k11 -k12 -k13 -k14 -k15 -k16 -k17 -k18 -k19 -k20 -k21 -k22 -k23 -k24 -k25 -k26 -k27 -k28 -k29 -k30 -k31 -k32 -k1n -u -T $TMPDIR $FILE -o unique.tsv

rm $FILE

zip -9 unique.zip unique.tsv
