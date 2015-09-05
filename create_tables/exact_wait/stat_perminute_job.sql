use thomas_test;

DROP TABLE IF EXISTS state_perminute_job;

CREATE table
    state_perminute_job
stored as
    ORC
as select
    job_id,
    minute_start,
    system,
    min(user_key) as user_key,
    min(measure_date) as measure_date,
    min(queue) as queue,
    sum(if(state!='REQUESTED'
           and state!='EXPIRED'
           and allocatedtime<=minute_start*1000
           and requestedtime<=minute_start*1000
           and allocatedtime>0,
           memory,0)) as memory_job,
    sum(if(state!='REQUESTED'
           and state!='EXPIRED'
           and allocatedtime<=minute_start*1000
           and requestedtime<=minute_start*1000
           and allocatedtime>0,
           vcores,0)) as vcores_job
from
    eric_cluster_metrics_dev_4.container_time_series_alloc_and_run_extend as cts
where
    measure_date='2015-07-13'
group by
    job_id,
    minute_start,
    system
