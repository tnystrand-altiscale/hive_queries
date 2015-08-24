use thomas_test;

DROP TABLE IF EXISTS cluster_sec_running_stat;

CREATE table
    cluster_sec_running_stat
stored as
    ORC
as select
    minute_start,
    system,
    min(measure_date) as measure_date,
    sum(memory_job) as memory_cluster,
    sum(vcores_job) as vcores_cluster
from
    thomas_test.job_sec_REQUESTED_split_stat as jsr
GROUP by
    minute_start,
    system
