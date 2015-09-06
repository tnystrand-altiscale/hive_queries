#!/bin/bash
table="$1"
query="select * from $table limit 50"
tmpfile="tmp_$(date "+%d%m%Y-%T")_$table.csv"

echo "$query"
echo $tmpfile

hive -e "$query" > $tmpfile && vi $tmpfile -c "set nowrap"
rm $tmpfile
