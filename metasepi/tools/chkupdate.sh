#!/bin/bash

ATSFILES=`find metasepi -name "*.?ats"`

for i in $ATSFILES; do
    awk -f metasepi/tools/chkupdate.awk $i
done
