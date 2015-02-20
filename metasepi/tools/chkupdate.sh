#!/bin/bash

ATSFILES=`find metasepi -name "*.?ats"`

for i in $ATSFILES; do
    eval `awk -f metasepi/tools/chkupdate.awk $i` | cat
done
