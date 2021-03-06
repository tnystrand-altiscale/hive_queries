use thomas_test;

DROP TABLE IF EXISTS job_min_REQUESTED_split_stat;

CREATE table
    job_min_REQUESTED_split_stat
stored as
    ORC
as select
    job_id,
    minute_start,
    system,
    min(measure_date) as measure_date,
    min(queue) as queue,
    sum(if(state='REQUESTED' or state='EXPIRED',0,memory)) as memory_job,
    sum(if(state='REQUESTED' or state='EXPIRED',0,vcores)) as vcores_job
from
    eric_cluster_metrics_dev_4.container_time_series_vhacked_with_unagg as cts
--where
    --measure_date='2015-07-13'
group by
    job_id,
    minute_start,
    system
