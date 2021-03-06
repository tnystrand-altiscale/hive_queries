use thomas_test;

DROP TABLE IF EXISTS job_sec_waiting_container_stats;

CREATE table
    job_sec_waiting_container_stats
stored as
    ORC
as select
    minute_start,
    system,
    min(measure_date) as measure_date,
    job_id,
    min(queue) as queue,
    count(*) as number_waiting_containers_job,
    sum(memory) as memory_of_waiting_containers_job,
    sum(vcores) as vcore_of_waiting_containers_job
from
    eric_cluster_metrics_dev_5.container_time_series as cts
where
    container_wait_time>10
--    and measure_date='2015-07-13'
GROUP by
    job_id,
    minute_start,
    system
