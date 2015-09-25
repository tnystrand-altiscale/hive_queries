#!/bin/bash

../../run_hive.sh initial_spark_compare.sql
hive -e "select * from thomas_test.initial_spark_compare" > tmp.csv
