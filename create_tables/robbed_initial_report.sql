use thomas_test;

drop table if exists robbed_initial_report;

create table robbed_initial_report 
as select 
    jis.*,
   
    mm.measure_date, 
    
    mm.num_waited_containers_min, 
    mm.num_waited_containers_sec,
    mm.memory_waiting_min,
    mm.memory_waiting_sec,
    mm.memory_waiting_min_converted,
    mm.vcores_waiting_min,
    mm.vcores_waiting_sec,
    mm.vcores_waiting_min_converted,
    
    mm.memory_max_capacity_robbed_ratio_min, 
    mm.memory_max_capacity_robbed_ratio_sec, 
    mm.vcr_capped_per_waiting_container_min, 
    mm.vcr_capped_per_waiting_container_sec,
    mm.memory_elastic_unfairness_robbed_ratio_min,
    mm.memory_elastic_unfairness_robbed_ratio_sec,
    mm.vcr_elastic_unfairness_robbed_ratio_min,
    mm.vcr_elastic_unfairness_robbed_ratio_sec,
    mm.memory_competing_jobs_robbed_min,
    mm.memory_competing_jobs_robbed_sec,    
    mm.vcr_competing_jobs_robbed_min,
    mm.vcr_competing_jobs_robbed_sec,
    
    mm.min_max_waiting_containers, 
    mm.sec_max_waiting_containers, 
    mm.min_avg_waiting_containers, 
    mm.sec_avg_waiting_containers, 
    mm.min_max_waiting_mem_containers, 
    mm.sec_max_waiting_mem_containers, 
    mm.min_avg_waiting_mem_containers, 
    mm.sec_avg_waiting_mem_containers, 
    mm.min_max_waiting_vcr_containers, 
    mm.sec_max_waiting_vcr_containers, 
    mm.min_avg_waiting_vcr_containers, 
    mm.sec_avg_waiting_vcr_containers,
    
    jf.finishtime-jf.launchtime as jobtime,
    jf.launchtime as jobstarttime
from
    memory_max_capacity_granularity_join as mm, 
    job_ineff_stats as jis, 
    cluster_metrics_prod_1.job_fact as jf 
where 
    jf.date between '2015-07-01' and '2015-07-30' 
    and mm.job_id=substr(jf.id,38,30) 
    and mm.job_id=jis.jobid
