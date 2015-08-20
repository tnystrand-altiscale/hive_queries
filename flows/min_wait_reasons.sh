#!/bin/bash

echo '================================================================='
echo '::::::::::::::::::::::::::::QUERY 1::::::::::::::::::::::::::::::'

hive -f ../create_tables/job_min_REQUESTED_split_stat.sql

echo '================================================================='
echo '::::::::::::::::::::::::::::QUERY 2::::::::::::::::::::::::::::::'

hive -f ../create_table/cluster_min_running_stat.sql

echo '================================================================='
echo '::::::::::::::::::::::::::::QUERY 3::::::::::::::::::::::::::::::'

hive -f ../create_tables/job_min_with_queue_lim.sql

#echo '================================================================='
#echo '::::::::::::::::::::::::::::QUERY 4::::::::::::::::::::::::::::::'
#
#hive -f ../create_tables/container_time_series_extended_min.sql
#
#echo '================================================================='
#echo '::::::::::::::::::::::::::::QUERY 5::::::::::::::::::::::::::::::'
#
#hive -f ../create_tables/job_wait_reasons_min_granularity.sql
