set START_DATE='2015-07-10';
set END_DATE='2015-07-10';

use thomas_test;

DROP TABLE IF EXISTS state_perminute_job;

CREATE table
    state_perminute_job
stored as
    ORC
as
with job_level
    as (
    select
        job_id,
        minute_start,
        system,
        min(user_key) as user_key,
        min(measure_date) as measure_date,
        min(queue) as queue,
        -- What is taking up memory in the beginng of the minute?
        -- Filter for all containers that are at least allocated at beginning of minute
        -- Container time series does not show allocated or acquired states for small times
        -- This is a problem, since some memory will be sceduled before the minute, but not recorded
        -- after. This can be fixed if grouping by container_id's.
        -- For each running/allocated/acquired container, check if allocation time < minute_start
        sum(
            case when state='ALLOCATED' 
                    and allocatedtime<bigint(minute_start)*1000
                    then container_size
                when state='ACQUIRED'
                    and acquiredtime<bigint(minute_start)*1000
                    then container_size
                when state='RUNNING'
                    and runningtime<bigint(minute_start)*1000
                    then container_size
            else 0 end) as memory_job,

        sum(
            case when state='ALLOCATED'
                    and allocatedtime<bigint(minute_start)*1000
                    then container_vcores 
                when state='ACQUIRED'
                    and acquiredtime<bigint(minute_start)*1000
                    then container_vcores
                when state='RUNNING'
                    and runningtime<bigint(minute_start)*1000
                    then container_vcores
            else 0 end) as vcores_job,
        -- What is waiting in the beginning of the minute?
        -- Some REQUESTED are missing from the container_time_series
        -- however this is unimportant since these are only <1 waiting sec.
        sum(if(state='REQUESTED'
               and requestedtime<bigint(minute_start)*1000,
               container_size,0)) as memory_REQ_job,
        sum(if(state='REQUESTED'
               and requestedtime<bigint(minute_start)*1000,
               container_vcores,0)) as vcores_REQ_job
    from
        eric_cluster_metrics_dev_4.container_time_series_alloc_and_run_extend as cts
    where
        measure_date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
    group by
        job_id,
        minute_start,
        system
    ),
    user_level
    as (
    select
        minute_start,
        queue,
        user_key,
        min(system) as system,
        sum(memory_job) as memory_user,
        sum(vcores_job) as vcores_user
    from
        job_level
    group by
        user_key,
        queue,
        minute_start,
        system
    ),
    queue_level
    as (
    select
        minute_start,
        queue,
        min(system) as system,
        sum(memory_user) as memory_queue,
        sum(vcores_user) as vcores_queue
    from
        user_level
    group by
        queue,
        minute_start,
        system
    ),
    cluster_level
    as (
    select
        minute_start,
        min(system) as system,
        sum(memory_queue) as memory_cluster,
        sum(vcores_queue) as vcores_cluster
    from
        queue_level
    group by
        minute_start,
        system
    )
select
    jl.job_id,
    jl.minute_start,
    jl.system,
    jl.user_key,
    jl.measure_date,
    jl.queue,
    jl.memory_REQ_job,
    jl.memory_job,
    ul.memory_user,
    ql.memory_queue,
    cl.memory_cluster,
    jl.vcores_REQ_job,
    jl.vcores_job,
    ul.vcores_user,
    ql.vcores_queue,
    cl.vcores_cluster,
    cc.memory_capacity,
    cc.memory_max_capacity,
    cc.cluster_memory_capacity,
    cc.vcore_capacity,
    cc.vcore_max_capacity,
    cc.cluster_vcore_capacity
from
    cluster_level as cl
join
    queue_level as ql
on (cl.minute_start=ql.minute_start and cl.system=ql.system)
join
    user_level as ul
on (ql.minute_start=ul.minute_start and ql.system=ul.system and ql.queue=ul.queue)
join
    job_level as jl
on (ul.minute_start=jl.minute_start and ul.system=jl.system and ul.queue=jl.queue and ul.user_key=jl.user_key)
join
    capacity_combined_avgd_hour as cc
on (floor(jl.minute_start/3600)=floor(cc.timestamp/3600)
    and jl.system=cc.queue_system
    and jl.queue=cc.queue_name
    and jl.measure_date=cc.queue_date)

