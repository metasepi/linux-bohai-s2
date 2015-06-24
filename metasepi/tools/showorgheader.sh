#!/bin/bash

simplepath () {
    REALPATH=`realpath $1`
    awk "BEGIN { str = \"${REALPATH}\"; sub(\"${PWD}/\", \"\", str); print str }"
}

SIMPLEPATH=`simplepath $1`
GITLOG=`git log ${SIMPLEPATH} | head -1`
GITCOMMIT=`awk "BEGIN { str = \"${GITLOG}\"; sub(/^commit +/, \"\", str); print str }"`

cat <<EOF
(*
 * OriginalCode: ${GITCOMMIT} ${SIMPLEPATH}
 *)
EOF
