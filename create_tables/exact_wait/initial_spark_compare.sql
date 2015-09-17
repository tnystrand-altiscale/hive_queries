use thomas_test;

drop table if exists initial_spark_compare;

create table initial_spark_compare
as select
    jc.*, 
    jw.memory_waiting,
    jw.max_mem_capacity_robbed_mbsec,
    jw.elastic_unfairness_mem_capped_mbsec,
    jw.competing_job_mem_capped_mbsec
from
    job_categories_from_spark as jc,
    job_wait_reasons_sec_granularity as jw
where
    jc.job_id=jw.job_id
