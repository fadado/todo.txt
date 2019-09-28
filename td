#!/bin/bash

#declare -r TMP="/tmp/td.tmp.$$"
#trap "rm -f $TMP" EXIT

function die {
	echo 1>&2 "${0#*/}: $@"
	exit 1
}

function sort-by-priority
{
	sed -e '/^([A-Z]) /!s/^/(€) /'	\
	| LC_ALL=C sort --stable	\
	| sed -e 's/^(€) //'
}

function index-by-tag
{
	local -r SIGIL=$1
	local -r SPC=' \t\v\f\n\r\d160' L='\cA' R='\cB'
	local -r TAG="\(${SIGIL}[^${SPC}]\+\)"

#	1. tag => ${L}tag${R}
#	2. ...tag => tag
#	3. remove suffix if present
#	4. remove prefix before first tag if present
#	5. add SIGIL to $
	sed -e "s/\(^\| \)${TAG}/${L}\2${R}/g"  \
	    -e "s/[^${L}]\+${L}${TAG}${R}/\1/g" \
	    -e "s/ .*$//"			\
	    -e "s/^[^${SIGIL}]\+//"		\
	    -e "s/$/${SIGIL}€/"	# € as highest character
}

function sort-by-tag
{
	sort --ignore-case --stable --field-separator=$'\t' --key=1,1
}

########################################################################
# Main
########################################################################

# Search todo.txt file
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
[[ -n "$TODOTXT" ]] || die "todo.txt file not found"

# test sortings
case $1 in
	p|priority)
		< "${TODOTXT}" sort-by-priority
		;;
	t|project) # Index projects
		< "${TODOTXT}"		\
		index-by-tag '+' 	\
		| paste - "${TODOTXT}"	\
		| sort-by-tag 		\
		| cut -f2
		;;
	c|context) # Index context
		< "${TODOTXT}"		\
		index-by-tag '@' 	\
		| paste - "${TODOTXT}" 	\
		| sort-by-tag		\
		| cut -f2
		;;
	s|show)
		# less -N "${TODOTXT}"
		nl "${TODOTXT}"
		;;
	*) die 'Unkown option';;
esac

exit 0
