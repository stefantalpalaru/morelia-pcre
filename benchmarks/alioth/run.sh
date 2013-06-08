#!/bin/sh

for F in regexdna.py regexdna_pcre.py; do
	echo ${F}
	time python ${F} < data.txt > /dev/null
done

