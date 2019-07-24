#!/usr/bin/env bash

sed -i -e 's/TRUE/true/g ; s/FALSE/false/g ; s/,[^,]*,/,/' *.csv
