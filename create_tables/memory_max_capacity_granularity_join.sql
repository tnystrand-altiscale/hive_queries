use thomas_test;

drop table if exists memory_max_capacity_granulatrity_join;

create table
    memory_max_capacity_granulatrity_join
stored as
    ORC
as select
    jm.job_id as min_job_id,
    js.job_id as sec_job_id,
    jm.num_waited_containers as min_num_waited_containers,
    js.num_waited_containers as sec_num_waited_containers,
    jm.num_max_mem_capacity_waited_containers/jm.num_waited_containers as min_num_mem_capped_ratio,
    js.num_max_mem_capacity_waited_containers/js.num_waited_containers as sec_num_mem_capped_ratio,
    jm.num_max_vcr_capacity_waited_containers/jm.num_waited_containers as min_num_vcr_capped_ratio,
    js.num_max_vcr_capacity_waited_containers/js.num_waited_containers as sec_num_vcr_capped_ratio,
    jm.system as min_system,
    js.system as sec_system
from
    thomas_test.job_wait_reasons_min_granularity as jm
full outer join
    thomas_test.job_wait_reasons_sec_granularity as js
on
    jm.job_id=js.job_id
where
    (jm.system='iheartradio' or jm.system='marketshare' or jm.system='visiblemeasures') and
    (js.system='iheartradio' or js.system='marketshare' or js.system='visiblemeasures')
