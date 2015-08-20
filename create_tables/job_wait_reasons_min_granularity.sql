use thomas_test;
    
drop table if exists job_wait_reasons_min_granularity;

create table
    job_wait_reasons_min_granularity
stored as
    ORC
as select
    job_id,
    system,
    min(measure_date) as measure_date,

    sum(cts.memory) as memory_waiting,
    sum(cts.vcores) as vcores_waiting,
    sum(cts.memory_seconds_from_minutes_waiting_longer_than_30) as
	memory_seconds_from_minutes_waiting_longer_than_30,       
    --sum(cts.DBG_sec_memory) as DBG_MBmin_over_thres,
    
    
    max(cts.container_wait_time) as max_container_wait_time,
    count(*) as num_waited_containers,
    sum(case when (cts.memory_job > 0.9*cts.memory_max_capacity) then cts.memory else 0 end) as max_mem_capacity_robbed_MBmin,
    sum(case when (cts.vcores_job > 0.9*cts.vcore_max_capacity ) then cts.vcores else 0 end) as max_vcr_capacity_robbed_VCRmin,
    sum(case when (cts.memory_cluster > 0.9*cts.total_cluster_memory and cts.memory_job > 0.9*memory_capacity) then cts.memory else 0 end)
        as elastic_unfairness_mem_capped_MBmin,
    sum(case when (cts.vcores_cluster > 0.9*cts.total_cluster_vcores and cts.vcores_job > 0.9*vcore_capacity) then cts.vcores else 0 end)
        as elastic_unfairness_vcore_capped_VCRmin
from
    thomas_test.container_time_series_extended_min as cts
group by
    job_id,
    system
