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
        sum(if(state!='REQUESTED'
               and state!='EXPIRED'
               and allocatedtime<=bigint(minute_start)*1000
               and requestedtime<=bigint(minute_start)*1000
               and allocatedtime>0,
               memory,0)) as memory_job,
        sum(if(state!='REQUESTED'
               and state!='EXPIRED'
               and allocatedtime<=bigint(minute_start)*1000
               and requestedtime<=bigint(minute_start)*1000
               and allocatedtime>0,
               vcores,0)) as vcores_job
    from
        eric_cluster_metrics_dev_4.container_time_series_alloc_and_run_extend as cts
    where
        measure_date='2015-07-13'
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
    jl.memory_job,
    ul.memory_user,
    ql.memory_queue,
    cl.memory_cluster,
    jl.vcores_job,
    ul.vcores_user,
    ql.vcores_queue,
    cl.vcores_cluster
from
    cluster_level as cl
join
    queue_level as ql
on (cl.minute_start=ql.minute_start and cl.system=ql.system)
join
    user_level as ul
on (ql.minute_start=ul.minute_start and ql.system=ul.system)
join
    job_level as jl
on (ul.minute_start=jl.minute_start and ul.system=jl.system)



