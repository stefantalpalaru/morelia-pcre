#!/bin/sh

FILENAME_COMMON="bm_regex_"
ARGS="--take_geo_mean -n 10"

for PART in "compile" "effbot" "v8"; do
	for LIB in "" "_pcre"; do
		F="${FILENAME_COMMON}${PART}${LIB}.py"
		echo "$F"
		"./$F" $ARGS
	done
done
