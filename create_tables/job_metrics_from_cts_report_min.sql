use thomas_test;
    
drop table if exists job_metrics_from_cts_report_min;

create table
    job_metrics_from_cts_report_min
as with job_metrics_gather
    as (
    select
        job_id,
        system,
        max(number_waiting_containers_job) as max_waiting_containers,
        avg(number_waiting_containers_job) as avg_waiting_containers,
        max(memory_of_waiting_containers_job) as max_waiting_mem_containers,
        avg(memory_of_waiting_containers_job) as avg_waiting_mem_containers,
        max(vcore_of_waiting_containers_job) as max_waiting_vcr_containers,
        avg(vcore_of_waiting_containers_job) as avg_waiting_vcr_containers
    from
        job_min_waiting_container_stats
    group by
        job_id,
        system
    )
select
    jwr.*,
    jmg.max_waiting_containers,
    jmg.avg_waiting_containers,
    jmg.max_waiting_mem_containers,
    jmg.avg_waiting_mem_containers,
    jmg.max_waiting_vcr_containers,
    jmg.avg_waiting_vcr_containers
from
    thomas_test.job_wait_reasons_min_granularity as jwr,
    job_metrics_gather as jmg
where
    jmg.job_id=jwr.job_id and
    jmg.system=jwr.system
