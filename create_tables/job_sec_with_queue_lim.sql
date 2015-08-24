use thomas_test;

drop table if exists job_sec_with_queue_lim;

create table
    job_sec_with_queue_lim
stored as
    ORC
as with tmp_job_sec_with_queue_lim
    as (
    select
        js.*,
        cc.memory_capacity,
        cc.memory_max_capacity,
        cc.cluster_memory_capacity,
        cc.vcore_capacity,
        cc.vcore_max_capacity,
        cc.cluster_vcore_capacity
    from
        thomas_test.job_sec_requested_split_stat as js,
        thomas_test.capacity_combined_avgd_hour as cc
    where
        js.queue=cc.queue_name
        and js.system=cc.queue_system
        and js.measure_date=cc.queue_date
        and floor(js.minute_start/3600)*3600000=cc.timestamp
    )
select 
    tjs.*,
    cs.memory_cluster,
    cs.vcores_cluster
from
    tmp_job_sec_with_queue_lim as tjs,
    cluster_sec_running_stat as cs
where
    tjs.system = cs.system
    and tjs.measure_date = cs.measure_date
    and tjs.minute_start = cs.minute_start
