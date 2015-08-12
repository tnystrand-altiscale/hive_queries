use thomas_test;

DROP TABLE IF EXISTS job_min_REQUESTED_split_stat;

CREATE table
    job_min_REQUESTED_split_stat
stored as
    ORC
as select
    cts.minute_start,
    cts.system,
    cts.date,
    cts.job_id,
    cts.queue,
    sum(cts.memory) as memory_job,
    sum(cts.vcores) as vcores_job
from
    eric_cluster_metrics_dev_4.container_time_series as cts
where
    cts.state!='REQUESTED' and
    cts.state!='EXPIRED' and
    --cts.date>='2015-05-08' and
    --cts.date<='2015-05-17'
    cts.date='2015-07-13'
GROUP by
    cts.job_id,
    cts.queue,
    cts.minute_start,
    cts.system,
    cts.date -- This is OK since group by minute already;
