#!/bin/bash

if [[ $1 == 1 ]]; then
    echo "THIS IS 1"

    hive -e "select * from thomas_test.request_assign_release_from_cf where jobid='job_1435714271812_19682'"> etmp.csv
    hive -e "select * from thomas_test.state_perminute_job where job_id='job_1435714271812_19682'"> stmp.csv

else
    echo "NOW THIS IS 2"

    hive -e "select * from thomas_test.request_assign_release_from_cf where minute_start=1436796000 and system='iheartradio'"> serie_debug.csv
    hive -e "select * from thomas_test.state_perminute_job where minute_start=1436796000"> state_debug.csv

fi
