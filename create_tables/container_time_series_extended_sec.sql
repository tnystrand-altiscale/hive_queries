use thomas_test;

drop table if exists container_time_series_extended_sec;

create table
    container_time_series_extended_sec
stored as
    ORC
as select
    js.job_id,
    js.system,
    js.measure_date,
    js.minute_start,
    js.queue,
    cts.container_wait_time,
    cts.memory,
    cts.container_id,
    cts.vcores,
   -- Memory related
    js.memory_job,
    js.memory_cluster,
    js.memory_capacity,
    js.memory_max_capacity,
    cts.cluster_memory as total_cluster_memory,
    -- Vcore related
    js.vcores_job,
    js.vcores_cluster,
    js.vcore_capacity,
    js.vcore_max_capacity,
    js.cluster_vcore_capacity as total_cluster_vcores

from
    thomas_test.job_sec_with_queue_lim as js,
    eric_cluster_metrics_dev_5.container_time_series as cts
where
    cts.container_wait_time > 30 and
    --cts.measure_date        = '2015-07-13' and
    --cts.minute_start between 1436745600 and 1436746200 and
    --(cts.state = 'REQUESTED' or cts.state='EXPIRED') and
    js.job_id       = cts.job_id        and
    js.minute_start = cts.minute_start  and
    js.system       = cts.system

