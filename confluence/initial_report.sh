#!/bin/bash

../flows/min_wait_reasons.sh&
../flows/sec_wait_reasons.sh&
../flows/permin_container_stats.sh&
../flows/persec_container_stats.sh&
wait
../flows/initial_report.sh
