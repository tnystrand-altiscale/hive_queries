#!/bin/bash

../flows/min_wait_reasons.sh&
../flows/sec_wait_reasons.sh&
wait
../flows/initial_report.sh
