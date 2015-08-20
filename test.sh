#!/bin/bash
logpath="$1.log"

logname=$(basename "$1")
 
if [ ! -f "$logpath" ]; then
    echo "Creating log dump for '$logpath'"
    touch $logpath
    echo "LOG DUMP FOR: $logname" > $logpath
    echo "-------------------------------------------------------------------" >> $logpath
fi


