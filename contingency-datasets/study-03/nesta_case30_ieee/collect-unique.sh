#!/usr/bin/env bash

TMPDIR=~/tmp 
FILE=$(mktemp -p $TMPDIR)

while read f
do
  grep -E '(Status|LIMITS|LOCALLY_SOLVED)' $f >> $FILE
done < <(find -name result-\*.tsv)

sort -k33 -k34 -k35 -k36 -k37 -k38 -k39 -k40 -k41 -k42 -k43 -k44 -k45 -k46 -k47 -k48 -k49 -k50 -k51 -k52 -k53 -k54 -k55 -k56 -k57 -k58 -k59 -k60 -k61 -k62 -k63 -k64 -k65 -k66 -k67 -k68 -k69 -k70 -k71 -k72 -k73 -k1n -u -T $TMPDIR $FILE -o unique.tsv

rm $FILE

zip -9 unique.zip unique.tsv
