use thomas_test;

drop table if exists memory_max_capacity_granularity_join;

create table
    memory_max_capacity_granularity_join
stored as
    ORC
as select
    --jm.job_id as min_job_id,
    --js.job_id as sec_job_id,
    jm.job_id,
    jm.system,
    jm.measure_date,

    -- container_time_series based metrics per minute/per second debug
    --jm.DBG_MBmin_over_thres,
    --js.DBG_MBsec_over_thres,
    --jm.DBG_MBmin_over_thres-js.DBG_MBsec_over_thres as dbg_diff
    
    jm.memory_waiting as memory_waiting_min,
    jm.memory_sec_convrt as memory_waiting_min_converted,
    js.memory_waiting as memory_waiting_sec,

    
    jm.vcores_waiting as vcores_waiting_min,
    jm.vcores_sec_convrt as vcores_waiting_min_converted,
    js.vcores_waiting as vcores_waiting_sec,
    
    jm.num_waited_containers as num_waited_containers_min,
    js.num_waited_containers as num_waited_containers_sec,

    
    --jm.max_container_wait_time as min_max_container_wait_time, 
    --js.max_container_wait_time as sec_max_container_wait_time,

    -- processed container_time_series based metrics
    jm.max_mem_capacity_robbed_MBmin/jm.memory_sec_convrt as memory_max_capacity_robbed_ratio_min, 
    js.max_mem_capacity_robbed_MBsec/js.memory_waiting as memory_max_capacity_robbed_ratio_sec,
    
    jm.max_vcr_capacity_robbed_VCRmin/jm.vcores_sec_convrt as vcr_capped_per_waiting_container_min, 
    js.max_vcr_capacity_robbed_VCRsec/js.vcores_waiting as vcr_capped_per_waiting_container_sec,
    
    jm.elastic_unfairness_mem_capped_MBmin/jm.memory_sec_convrt as memory_elastic_unfairness_robbed_ratio_min,
    js.elastic_unfairness_mem_capped_MBsec/js.memory_waiting as memory_elastic_unfairness_robbed_ratio_sec,
    
    jm.elastic_unfairness_vcore_capped_VCRmin/jm.memory_sec_convrt as vcr_elastic_unfairness_robbed_ratio_min,
    js.elastic_unfairness_vcore_capped_VCRsec/js.memory_waiting as vcr_elastic_unfairness_robbed_ratio_sec,
    
    jm.competing_job_mem_capped_MBmin/jm.memory_sec_convrt as memory_competing_jobs_robbed_min,
    js.competing_job_mem_capped_MBsec/js.memory_waiting as memory_competing_jobs_robbed_sec,
    
    jm.competing_job_vcore_capped_VCRmin/jm.memory_sec_convrt as vcr_competing_jobs_robbed_min,
    js.competing_job_vcore_capped_VCRsec/js.memory_waiting as vcr_competing_jobs_robbed_sec,
    
    -- direct container_fact based metrics
    -- per min and per second are not necessarily equal, per second can give smaller values
    jm.max_waiting_containers as min_max_waiting_containers,
    js.max_waiting_containers as sec_max_waiting_containers,
    
    jm.avg_waiting_containers as min_avg_waiting_containers,
    js.avg_waiting_containers as sec_avg_waiting_containers,
    
    jm.max_waiting_mem_containers as min_max_waiting_mem_containers,
    js.max_waiting_mem_containers as sec_max_waiting_mem_containers,
    
    jm.avg_waiting_mem_containers as min_avg_waiting_mem_containers,
    js.avg_waiting_mem_containers as sec_avg_waiting_mem_containers,
    
    jm.max_waiting_vcr_containers as min_max_waiting_vcr_containers,
    js.max_waiting_vcr_containers as sec_max_waiting_vcr_containers,
    
    jm.avg_waiting_vcr_containers as min_avg_waiting_vcr_containers,
    js.avg_waiting_vcr_containers as sec_avg_waiting_vcr_containers
    --jm.system as min_system,
    --js.system as sec_system
from
    thomas_test.job_metrics_from_cts_report_min as jm
full outer join
    thomas_test.job_metrics_from_cts_report_sec as js
on
    jm.job_id=js.job_id
--where
--    (jm.system='iheartradio' or jm.system='marketshare' or jm.system='visiblemeasures') and
--    (js.system='iheartradio' or js.system='marketshare' or js.system='visiblemeasures')
