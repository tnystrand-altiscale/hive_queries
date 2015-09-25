set START_DATE='2015-07-08';
set END_DATE='2015-07-14';
set FACT_TABLE=eric_cluster_metrics_dev_4.container_fact;

use thomas_test;

drop table if exists request_assign_release_from_cf;

create table request_assign_release_from_cf as

select 
    min(minute_start) as minute_start,
    timestamp,
    jobid,
    sum(memory) as memory,
    sum(vcores) as vcores,
    action as action,
    system as system,
    min(date) as date
from (
    -- request is made
    select
        int(bigint(requestedtime/60000)*60) as minute_start,
        requestedtime as timestamp,
        jobid,
        memory,
        vcores,
        0 as action,
        system,
        date
    from
        ${hiveconf:FACT_TABLE}
    where
        requestedtime>0
        and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
    
    union all
    
    -- only request to allovated
    select
        int(bigint(allocatedtime/60000)*60) as minute_start,
        allocatedtime as timestamp,
        jobid,
        memory,
        vcores,
        1 as action,
        system,
        date
    from
        ${hiveconf:FACT_TABLE}
    where
        allocatedtime>0
        and reservedtime=0
        and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
    
    union all
    
    -- only 'in use containers' which are deallocated
    select
        int(bigint((completedtime+killedtime+expiredtime+releasedtime)/60000)*60) as minute_start,
        completedtime+killedtime+expiredtime+releasedtime as timestamp,
        jobid,
        memory,
        vcores,
        2 as action,
        system,
        date
    from
        ${hiveconf:FACT_TABLE}
    where
        (completedtime>0 or killedtime>0 or expiredtime>0 or releasedtime>0)
        and (reservedtime=0 or (reservedtime>0 and allocatedtime>0))
        and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}

    union all

    -- reservation is made
    select
        int(bigint(reservedtime/60000)*60) as minute_start,
        reservedtime as timestamp,
        jobid,
        memory,
        vcores,
        3 as action,
        system,
        date
    from
        ${hiveconf:FACT_TABLE}
    where
        reservedtime>0
        and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}

    union all

    -- transition from reserved to allocated
    select
        int(bigint(allocatedtime/60000)*60) as minute_start,
        allocatedtime as timestamp,
        jobid,
        memory,
        vcores,
        4 as action,
        system,
        date
    from
        ${hiveconf:FACT_TABLE}
    where
        reservedtime>0
        and allocatedtime>0
        and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}

    union all

    -- reserved but never allocated and now removed
    select
        int(bigint((completedtime+killedtime+expiredtime+releasedtime)/60000)*60) as minute_start,
        completedtime+killedtime+expiredtime+releasedtime as timestamp,
        jobid,
        memory,
        vcores,
        5 as action,
        system,
        date
    from
        ${hiveconf:FACT_TABLE}
    where
        reservedtime>0
        and allocatedtime=0
        and (completedtime>0 or killedtime>0 or expiredtime>0 or releasedtime>0)
        and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
    ) tmp_union
group by
    timestamp,
    action,
    jobid,
    system
order by
    timestamp
