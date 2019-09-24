#!/bin/bash

# Temporal files
TMP="/tmp/td.tmp.$$"
trap "rm -f $TMP" EXIT

# Input todo.txt file
TODOTXT=TODO.txt

# Regexp:
#	1. substitute xxx[tag] => tag
#	2. remove suffix if present
#	3. remove prefix before first tag if present
#	4. add SIGIL to $
function index {
	local SIGIL=$1
	local SPC=' \t\v\f\n\r\d160'
	local TAG="\(^\| \)\(${SIGIL}[^${SPC}]\+\( \|$\)\)"

	sed -e "s/.*${TAG}/\2/g"\
	    -e "s/ .*$//"\
	    -e "s/^[^${SIGIL}]\+//"\
	    -e "s/$/${SIGIL}/"
}

# Index projects
index '+' < ${TODOTXT} > ${TMP}

# Index context
#index '@' < ${TODOTXT} > ${TMP}

paste ${TMP} ${TODOTXT} \
| sort --stable --field-separator=$'\t' --key=1,1 \
| cut -f2

exit 0
