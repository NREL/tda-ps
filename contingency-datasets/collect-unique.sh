#!/usr/bin/env bash

find -name result-\*.tsv -exec cat {} \; | pv -l | sort -k3 -k4 -k5 -k6 -k7 -k8 -k9 -k10 -k11 -k12 -k13 -k14 -k15 -k16 -k17 -k18 -k19 -k20 -k21 -k22 -k23 -k24 -k25 -k26 -k27 -k28 -k29 -k30 -k31 -k32 -u -T ~/tmp/ > unique.tsv
zip -9 unique.zip unique.tsv
