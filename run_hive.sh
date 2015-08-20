#!/bin/bash
logpath="$1.log"
outpath="$1.dat"

logname=$(basename "$1")
timestamp="$(date)"
 
if [ ! -f "$logpath" ]; then
    echo "Creating new log dump as '$logpath'"
    echo "Creating new dat dump as '$outpath'"
    touch $logpath
    touch $outpath

    echo "###################################################################" >> $logpath
    echo "LOG DUMP FOR: $logname" >> $logpath
    echo "###################################################################" >> $logpath
    echo "===================================================================" >> $logpath
    echo "" >> $logpath

    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $outpath
    echo "DAT DUMP FOR: $logname" >> $outpath
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $outpath
    echo "===================================================================" >> $outpath
    echo "" >> $outpath
fi

echo "===================================================================" >> $logpath
cat $1 >> $logpath
echo "-------------------------------------------------------------------" >> $logpath
echo "Starting query at: $(date)" >> $logpath
echo "-------------------------------------------------------------------" >> $logpath
echo "" >> $logpath

echo "===================================================================" >> $outpath
cat $1 >> $outpath
echo "-------------------------------------------------------------------" >> $outpath
echo "Starting query at: $(date)" >> $outpath
echo "-------------------------------------------------------------------" >> $outpath
echo "" >> $outpath

hive -f $1 1>>$outpath 2> >(tee -a $logpath >&2)

