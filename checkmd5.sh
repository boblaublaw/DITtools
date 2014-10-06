#!/bin/sh

find "$1" -name "*.md5" | while read hashfile; do 
	hash=`cat "$hashfile"`
	fname=`basename "$hashfile" .md5`
	dname=`dirname "$hashfile"`
	pname="$dname/$fname" 
	which md5sum > /dev/null 2> /dev/null
	if [ $? -eq 0 ]; then
		testhash=`md5sum "$pname" | cut -f1 -d\ `
	else
        which md5 > /dev/null 2> /dev/null
        if [ $? -eq 0 ]; then
        	testhash=`md5 "$pname" | cut -f2 -d\= | cut -c2-`
        else
    		echo md5sum or md5 required
    	fi
	fi
	if [ $hash != $testhash ]; then 
		echo MISMATCH $pname
        exit
	fi
done

	
