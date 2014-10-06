#!/bin/sh


# some example SRC, RELSRC, and DST values:

# from CIFS to HFS
#SRC=/Volumes/workspace/projects/video
#RELSRC="Focus source media"
#DST=/Volumes/FOCUS/Focus

# from CIFS to SSD
#SRC=/Volumes/workspace/projects/video
#RELSRC="Focus source media"
#DST=~/Desktop/Focustest

# from SSD to HFS
#SRC=~/Desktop/Focustest
#RELSRC="Focus source media"
#DST=/Volumes/FOCUS/Focus

SRC="$1"
RELSRC="$2"
DST="$3"

# copy just the md5 files over
cd "$SRC" 
find "$RELSRC" -name "*md5" -type f | rsync -a --files-from=- . "$DST"

# for each md5, check if the dest file exists and if the hash matches
find "$RELSRC" -name "*md5" -type f | while read relhashfile; do 
    fname=`basename "$relhashfile" .md5`
    srchashfile="$SRC"/$relhashfile
    dsthashfile="$DST"/$relhashfile
    srcdirname=`dirname "$srchashfile"`
    dstdirname=`dirname "$dsthashfile"`
    srcpathname="$srcdirname/$fname"
    dstpathname="$dstdirname/$fname"
    if [ -f "$dstpathname.done" ]; then
        echo $dstpathname is already confirmed.
        continue
    fi
    testhash=poop
    if [ -f "$dstpathname" ]; then
        testhash=`md5 "$dstpathname" | cut -f2 -d\= | cut -c2-`
    fi
    hash=`cat "$dsthashfile"`
    if [ $testhash = $hash ] ; then
        touch "$dstpathname.done"
        echo $dstpathname is newly confirmed.
        continue
    fi 
    echo copying $dstpathname
    rm -f "$dstpathname"
    cp -f "$srcpathname" "$dstpathname"
    if [ $? -ne 0 ]; then
        echo copy failed!
        exit
    fi
    testhash=`md5 "$dstpathname" | cut -f2 -d\= | cut -c2-`
    hash=`cat "$dsthashfile"`
    while [ $testhash != $hash ] ; do
        echo $dstpathname FAILED confirmation. confirming source file.
        testhash=`md5 "$srcpathname" | cut -f2 -d\= | cut -c2-`
        if [ $testhash != $hash ] ; then
            echo SOURCE FILE FAILED HASH CHECK
            exit
        fi
        echo source file is fine, retrying copy to $dstpathname
        rm -f "$dstpathname"
        cp -f "$srcpathname" "$dstpathname"
        if [ $? -ne 0 ]; then
            echo copy failed!
            exit
        fi
        testhash=`md5 "$dstpathname" | cut -f2 -d\= | cut -c2-`
    done
    echo $dstpathname is newly confirmed.
    touch "$dstpathname.done"
done


