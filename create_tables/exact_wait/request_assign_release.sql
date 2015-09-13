set START_DATE='2015-07-10';
set END_DATE='2015-07-10';

use thomas_test;

drop table if exists request_assign_release;

create table
    request_assign_release (
        minute_start    int,
        timestamp       bigint,
        jobid           string,
        memory          int,
        action          int
    )
partitioned by (
    system string,
    date string
    )
stored as
    orc;

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;


insert overwrite table request_assign_release
partition(system,date)
select
    int(bigint(timestamp/60000)*60) as minute_start,
    timestamp,
    concat('job_',substr(appid,13)) as jobid,
    memory,
    0 as action,
    system,
    date
from
    dp_prod_1_resourcemanager_events.container_request
where
    date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
union all
select
    int(bigint(timestamp/60000)*60) as minute_start,
    timestamp,
    concat('job_',split(id,'[_]')[1],'_',split(id,'[_]')[2]) as jobid,
    memory,
    case action
        when 'Assigned' then 1
        when 'Released' then 2
    else -1
    end as action,
    system,
    date
from
    dp_prod_1_resourcemanager_events.assign_release
where
    date between ${hiveconf:START_DATE} and ${hiveconf:END_DATE}
order by
    timestamp
