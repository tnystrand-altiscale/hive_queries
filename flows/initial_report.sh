#!/bin/bash

echo '================================================================='
echo '::::::::::::::::::::::::::::QUERY 1::::::::::::::::::::::::::::::'

hive -f ../create_tables/memory_max_capacity_granularity_join.sql

echo '================================================================='
echo '::::::::::::::::::::::::::::QUERY 2::::::::::::::::::::::::::::::'

hive -f ../create_tables/robbed_initial_report.sql



