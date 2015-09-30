--set STATE_TIME=1436511180000;
--set STATE_DATE='2015-07-10';
--set STATE_DATE_BEG='2015-07-09';

set STATE_TIME=1436749213024;
set STATE_DATE='2015-07-13';
set STATE_DATE_BEG='2015-07-12';

use thomas_test;

with job_level as
    (
    select
        jobid,
        ${hiveconf:STATE_TIME} as minute_start,

        sum(
            if  (
                (
                (allocatedtime <= ${hiveconf:STATE_TIME} and allocatedtime>0)
                or
                (reservedtime <= ${hiveconf:STATE_TIME} and reservedtime>0)
                )
                and
                (
                completedtime >= ${hiveconf:STATE_TIME}
                or
                releasedtime >= ${hiveconf:STATE_TIME}
                or
                expiredtime >= ${hiveconf:STATE_TIME}
                or
                killedtime >= ${hiveconf:STATE_TIME}
                )
                ,
                memory,
                0
                )
            ) as memory_job,

        sum(
            if  (
                (
                (allocatedtime <= ${hiveconf:STATE_TIME} and allocatedtime>0)
                or
                (reservedtime <= ${hiveconf:STATE_TIME} and reservedtime>0)
                )
                and
                (
                completedtime >= ${hiveconf:STATE_TIME}
                or
                releasedtime >= ${hiveconf:STATE_TIME}
                or
                expiredtime >= ${hiveconf:STATE_TIME}
                or
                killedtime >= ${hiveconf:STATE_TIME}
                )
                ,
                memory,
                0
                )
            ) as vcores_job,

        sum(
            if  (
                requestedtime <= ${hiveconf:STATE_TIME} and requestedtime>0
                and
                (
                allocatedtime >= ${hiveconf:STATE_TIME}
                or
                (
                    (
                    completedtime >= ${hiveconf:STATE_TIME}
                    or
                    releasedtime >= ${hiveconf:STATE_TIME}
                    or
                    expiredtime >= ${hiveconf:STATE_TIME}
                    or
                    killedtime >= ${hiveconf:STATE_TIME}
                    )
                    and
                    allocatedtime=0
                    )
                )
                ,
                memory,
                0
                )
            ) as req_memory,
        ${hiveconf:STATE_DATE} as date,
        system,
        min(queue) as queue,
        min(user_key) as user_key
    from
        eric_cluster_metrics_dev_4.container_fact
    where
        date between ${hiveconf:STATE_DATE_BEG} and ${hiveconf:STATE_DATE}
        and system='iheartradio'
    group by
        jobid,
        system
    ),

    user_level as
    (
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

    queue_level as
    (
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

    cluster_level as
    (
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
    jobid,
    jl.minute_start,
    spj.minute_start as minute_start_state,
    jl.req_memory as memory_req_job_exact,
    jl.memory_job as memory_job_exact,
    ul.memory_user as memory_user_exact,
    ql.memory_queue as memory_queue_exact,
    cl.memory_cluster as memory_cluster_exact,
    spj.memory_req_job,
    spj.memory_job,
    spj.memory_user,
    spj.memory_queue,
    spj.memory_cluster,
    spj.memory_capacity,
    spj.memory_max_capacity,
    spj.cluster_memory_capacity,
    jl.user_key,
    jl.queue,
    jl.system,
    jl.date
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
    state_perminute_job as spj
on
    spj.minute_start=int(jl.minute_start/60000)*60
    and spj.system=jl.system
    and spj.job_id=jl.jobid;
