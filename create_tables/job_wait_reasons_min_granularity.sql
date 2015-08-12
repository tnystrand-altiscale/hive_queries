use thomas_test;
    
drop table if exists job_wait_reasons_min_granularity;

create table
    job_wait_reasons_min_granularity
stored as
    ORC
as select
    job_id,
    system,
    max(cts.container_wait_time) as max_container_wait,
    count(*) as num_waited_containers,
    sum(case when (cts.memory_job > 0.9*cts.memory_max_capacity) then 1 else 0 end) as num_max_mem_capacity_waited_containers,
    sum(case when (cts.vcores_job > 0.9*cts.vcore_max_capacity ) then 1 else 0 end) as num_max_vcr_capacity_waited_containers
from
    thomas_test.container_time_series_extended_min as cts
where
    cts.container_wait_time > 30
group by
    job_id,
    system
