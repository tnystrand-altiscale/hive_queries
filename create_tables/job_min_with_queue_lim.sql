use thomas_test;

drop table if exists job_min_with_queue_lim;

create table
    job_min_with_queue_lim
stored as
    ORC
as select
    js.*,
    cc.cluster_memory_capacity,
    cc.cluster_vcore_capacity,
    cc.capacity*cc.cluster_memory_capacity/100 as memory_capacity,
    cc.max_capacity*cc.cluster_memory_capacity/100 as memory_max_capacity,
    floor(cc.capacity*cc.cluster_vcore_capacity/100) as vcore_capacity,
    cc.max_capacity*cc.cluster_vcore_capacity/100 as vcore_max_capacity
from
    thomas_test.job_min_requested_split_stat as js,
    thomas_test.capacity_combined_avgd as cc
where
    js.queue=cc.queue_name and
    js.system=cc.queue_system and
    js.date=cc.queue_date
    --and js.minute_start=cc.timestamp/60000*60
