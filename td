#!/bin/bash

declare -r TMP="/tmp/td.tmp.$$"
trap "rm -f $TMP" EXIT

function die {
	echo 1>&2 "${0#*/}: $@"
	exit 1
}

# Regexp: (TODO)
#	1. substitute xxx[tag] => tag
#	2. remove suffix if present
#	3. remove prefix before first tag if present
#	4. add SIGIL to $
function index-by-tag {
	local -r SIGIL=$1
	local -r SPC=' \t\v\f\n\r\d160' L='\cA' R='\cB'
	local -r TAG="\(${SIGIL}[^${SPC}]\+\)"

	sed -e "s/\(^\| \)${TAG}/${L}\2${R}/g"  \
	    -e "s/[^${L}]\+${L}${TAG}${R}/\1/g" \
	    -e "s/ .*$//"			\
	    -e "s/^[^${SIGIL}]\+//"		\
	    -e "s/$/${SIGIL}/"
}

# todo.txt file
declare -r -a DIRECTORIES=(./ ~/ ~/.todo/)
declare -r -a FILENAMES=(todo.txt TODO.txt TODO.TXT)
for d in ${DIRECTORIES[@]}; do
	for f in ${FILENAMES[@]}; do
		if [[ -e $d$f ]]; then
			TODOTXT=$d$f
			break 2
		fi
	done
done
[[ -n $TODOTXT ]] || die "todo.txt file not found"

# test sortings

function sort_by_tag {
	LC_ALL=C sort --ignore-case --stable --field-separator=$'\t' --key=1,1
}

case $1 in
	p|priority)
		< ${TODOTXT} LC_ALL=C sort --stable
		;;
	t|project) # Index projects
		index-by-tag '+' < ${TODOTXT} > ${TMP}
		paste ${TMP} ${TODOTXT} \
		| sort_by_tag 		\
		| cut -f2
		;;
	c|context) # Index context
		index-by-tag '@' < ${TODOTXT} > ${TMP}
		paste ${TMP} ${TODOTXT} \
		| sort_by_tag		\
		| cut -f2
		;;
	*) ;;
esac

exit 0
