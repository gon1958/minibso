#!/bin/sh
#set -x
if [ ! -d "$1" ]
then
	echo "Target directory not exists!"
	exit 1
fi
CURDIR=`pwd`
CURDIR=`basename "$CURDIR"`
rm -rf "$1/$CURDIR"
rsync -av --progress ../${CURDIR} "$1"
