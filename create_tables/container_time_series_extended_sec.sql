use thomas_test;

drop table if exists container_time_series_extended_sec;

create table
    container_time_series_extended_sec
stored as
    ORC
as select
    js.job_id,
    js.system,
    js.date,
    js.minute_start,
    js.queue,
    cts.container_wait_time,
    -- Memory related
    js.memory_job,
    js.memory_capacity,
    js.memory_max_capacity,
    -- Vcore related
    js.vcores_job,
    js.vcore_capacity,
    js.vcore_max_capacity
from
    thomas_test.job_sec_with_queue_lim as js,
    eric_cluster_metrics_dev_5.container_time_series as cts
where
    cts.date        = '2015-07-13'      and
    (cts.state = 'REQUESTED' or cts.state='EXPIRED') and
    js.job_id       = cts.job_id        and
    js.queue        = cts.queue         and
    js.minute_start = cts.minute_start  and
    js.date         = cts.date          and
    js.system       = cts.system