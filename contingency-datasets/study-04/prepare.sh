#!/usr/bin/env bash

sed -i -e 's/"//g ; s/TRUE/true/g ; s/FALSE/false/g ; 1s/,/Sequence,/' *.csv
