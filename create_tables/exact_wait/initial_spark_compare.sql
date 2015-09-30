set START_DATE='2015-07-08';
set END_DATE='2015-07-14';
set FACT_TABLE=eric_cluster_metrics_dev_4.container_fact;

use thomas_test;

drop table if exists initial_spark_compare;

create table initial_spark_compare
as with exact_wait_time as (
    select
        jobid,
        system,
        min(queue) as queue,
        min(date) as date,
        min(if(requestedtime>0,requestedtime,reservedtime)) as launchtime,
        sum(
            case
                when (allocatedtime>0 and requestedtime>0) then
                    (allocatedtime-requestedtime)/1000*memory
                else
                    0
                end
            ) as total_waittime_exact,
        avg(
            case
                when (completed>0 and runningtime>0) then
                    (completed-runningtime)/1000*memory
                else
                    0
                end
            ) as avg_runningtime_exact
    from
        ${hiveconf:FACT_TABLE}
    where
        date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
    group by
        jobid,
        system
    )
select
    ew.launchtime,
    ew.date,
    ew.queue,
    ew.avg_runningtime_exact,
    jc.*,
    --jws.memory_waiting as memory_waiting_sec,
    ew.total_waittime_exact,
    --jws.max_mem_capacity_robbed_mbsec,
    jwn.max_mem_capacity_robbed_mbmin,
    jwn.memory_sec_convrt,
    --jws.elastic_unfairness_mem_capped_mbsec,
    jwn.elastic_unfairness_mem_capped_mbmin,
    --jws.competing_job_mem_capped_mbsec,
    jwn.competing_job_mem_capped_mbmin,
    --jws.max_vcr_capacity_robbed_vcrsec,
    jwn.max_vcr_capacity_robbed_vcrmin,
    --jws.elastic_unfairness_vcore_capped_vcrsec,
    jwn.elastic_unfairness_vcore_capped_vcrmin,
    --jws.competing_job_vcore_capped_vcrsec,
    jwn.competing_job_vcore_capped_vcrmin
from
    job_categories_from_spark as jc
--join
--    job_wait_reasons_sec_granularity as jws
--on
--    jc.job_id=jws.job_id
join
    job_wait_reasons_min_granularity as jwn
on
    jc.job_id=jwn.job_id
join
    exact_wait_time as ew
on
    jwn.job_id=ew.jobid

