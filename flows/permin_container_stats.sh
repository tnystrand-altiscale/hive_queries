#!/bin/bash

echo '================================================================='
echo '::::::::::::::::::::::::::::QUERY 1::::::::::::::::::::::::::::::'

hive -f ../create_tables/job_min_waiting_container_stats.sql

