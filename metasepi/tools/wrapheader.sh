#!/bin/bash

simplepath () {
    REALPATH=`realpath $1`
    awk "BEGIN { str = \"${REALPATH}\"; sub(\"${PWD}/\", \"\", str); print str }"
}

catspath () {
    SIMPLEPATH=$1
    DIR=`dirname ${SIMPLEPATH}`
    FILE=`basename ${SIMPLEPATH}`
    awk "BEGIN { str = \"${FILE}\"; sub(/\.h$/, \".cats\", str); print \"metasepi/${DIR}/CATS/\" str }"
}

satspath () {
    SIMPLEPATH=$1
    DIR=`dirname ${SIMPLEPATH}`
    FILE=`basename ${SIMPLEPATH}`
    awk "BEGIN { str = \"${FILE}\"; sub(/\.h$/, \".sats\", str); print \"metasepi/${DIR}/SATS/\" str }"
}

headerdef () {
    CATSPATH=$1
    awk "BEGIN { str = \"_${CATSPATH}\"; str = toupper(str); gsub(/[^A-Z]/, \"_\", str); print str }"
}

includpath () {
    SIMPLEPATH=$1
    if [[ "${SIMPLEPATH}" =~ ^include/ ]]; then
        awk "BEGIN { str = \"${SIMPLEPATH}\"; gsub(/^include\//, \"\", str); print str }"
    else
	echo ${SIMPLEPATH}
    fi
}

includecats () {
    CATSPATH=$1
    awk "BEGIN { str = \"${CATSPATH}\"; sub(/^metasepi\//, \"\", str); print str }"
}

HEADER=`simplepath $1`
CATS=`catspath ${HEADER}`
SATS=`satspath ${HEADER}`
HEADERDEF=`headerdef ${CATS}`
INCLUDEH=`includpath ${HEADER}`
INCLUDECATS=`includecats ${CATS}`

mkdir -p `dirname ${CATS}`
mkdir -p `dirname ${SATS}`

# SATS
cat > ${SATS} <<EOF
%{#
#include "${INCLUDECATS}"
%}
EOF

# CATS
cat > ${CATS} <<EOF
#ifndef ${HEADERDEF}
#define ${HEADERDEF}

#include <${INCLUDEH}>

#endif /* ${HEADERDEF} */
EOF
