use thomas_test;
    
drop table if exists job_wait_reasons_sec_granularity;

create table
    job_wait_reasons_sec_granularity
stored as
    ORC
as select
    job_id,
    system,
    min(measure_date) as measure_date,

    sum(memory) as memory_waiting,
    sum(vcores) as vcores_waiting,
        
    --sum(cts.DBG_sec_memory) as DBG_MBmin_over_thres,
    
    max(container_wait_time) as max_container_wait_time,
    count(*) as num_waited_containers,
    sum(case when (memory_job > 0.9*memory_max_capacity) then memory else 0 end) as max_mem_capacity_robbed_MBsec,
    sum(case when (vcores_job > 0.9*vcore_max_capacity ) then vcores else 0 end) as max_vcr_capacity_robbed_VCRsec,
    sum(case when (memory_cluster > 0.9*total_cluster_memory and memory_job < memory_capacity) then memory else 0 end)
        as elastic_unfairness_mem_capped_MBsec,
    sum(case when (vcores_cluster > 0.9*total_cluster_vcores and vcores_job < vcore_capacity) then memory else 0 end)
        as elastic_unfairness_vcore_capped_VCRsec,
    sum(case when (memory_cluster > 0.9*total_cluster_memory
                    and memory_job between memory_capacity and 0.9*total_cluster_memory) then memory else 0 end)
        as competing_job_mem_capped_MBsec,
    sum(case when (vcores_cluster > 0.9*total_cluster_vcores
                    and vcores_job between vcore_capacity and 0.9*total_cluster_vcores) then memory else 0 end)
        as competing_job_vcore_capped_VCRsec
        
from
    thomas_test.container_time_series_extended_sec as cts
group by
    job_id,
    system
