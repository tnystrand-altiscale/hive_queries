set START_DATE='2015-07-08';
set END_DATE='2015-07-14';

use thomas_test;

drop table if exists request_assign_release_from_cf_and_trans;

create table request_assign_release_from_cf_and_trans as

select 
    min(minute_start) as minute_start,
    timestamp,
    jobid,
    sum(memory) as memory,
    sum(vcores) as vcores,
    action as action,
    system as system,
    min(date) as date
from
    (
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
        eric_backup.container_fact
    where
        requestedtime>0
        and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
    
    union all
    
    select
        *
    from
        (
        select
            tu.minute_start,
            tu.timestamp,
            tu.jobid,
            cf.memory
            cf.vcores,
            tu,action,
            tu.system,
            tu.date
            
        from
            (
            select
                id,
                int(bigint(timestamp/60000)*60) as minute_start,
                timestamp,
                jobid,
                memory,
                vcores,
                1 as action,
                system,
                date
            from
                dp_prod_1_resourcemanager_events.transitions
            where
                `from`='NEW' and `to`='ALLOCATED'
                and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
            
            union all
            
            select
                id,
                int(bigint((completedtime+killedtime+expiredtime+releasedtime)/60000)*60) as minute_start,
                completedtime+killedtime+expiredtime+releasedtime as timestamp,
                jobid,
                memory,
                vcores,
                2 as action,
                system,
                date
            from
                dp_prod_1_resourcemanager_events.transitions
            where
                (`from`='RUNNING' and `to`='COMPLETED')
                or 
                (`from`='RUNNING' and `to`='KILLED')
                or
                (`from`='RUNNING' and `to`='RELEASED')
                or
                (`from`='ACQUIRED' and `to`='COMPLETED')
                or
                (`from`='ACQUIRED' and `to`='EXPIRED')
                or
                (`from`='ACQUIRED' and `to`='RELEASED')
                or
                (`from`='ACQUIRED' and `to`='KILLED')
                or
                (`from`='ALLOCATED' and `to`='KILLED')
                or
                (`from`='ALLOCATED' and `to`='EXPIRED')
                and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}

            union all

            select
                id,
                int(bigint(reservedtime/60000)*60) as minute_start,
                reservedtime as timestamp,
                jobid,
                memory,
                vcores,
                3 as action,
                system,
                date
            from
                eric_backup.container_fact
            where
                `from`='NEW' and `to`='RESERVED'
                and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}

            union all

            select
                id,
                int(bigint(allocatedtime/60000)*60) as minute_start,
                allocatedtime as timestamp,
                jobid,
                memory,
                vcores,
                4 as action,
                system,
                date
            from
                eric_backup.container_fact
            where
                `from`='RESERVED' and `to`='ALLOCATED'
                and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}

            union all

            select
                id,
                int(bigint((completedtime+killedtime+expiredtime+releasedtime)/60000)*60) as minute_start,
                completedtime+killedtime+expiredtime+releasedtime as timestamp,
                jobid,
                memory,
                vcores,
                5 as action,
                system,
                date
            from
                eric_backup.container_fact
            where
                `from`='RESERVED' and (`to`='KILLED' or `to`='EXPIRED' or `to`='RELEASED' or `to`='COMPLETED')
                and date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
            ) as tu

            join

            (
            select
                containerid,
                system,
                memory,
                vcores
            from
                cluster_metrics_prod_1.container_fact
            where
                date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
            ) as cf

            on

            tu.id = cf.containerid and
            tu.system = cf.system

        ) as transition_union_with_mem_and_vcores
    ) tmp_union
group by
    timestamp,
    action,
    jobid,
    system
order by
    timestamp
