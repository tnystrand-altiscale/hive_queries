use thomas_test;

drop table if exists job_ineff_stats;

create table job_ineff_stats

as select 
    jobid,
    avg(inefficiency) as inefficiency,
    sum(waitingtime) as waitingtime,
    sum(runningtime) as runningtime,
    sum(completingtime) as totaltime
from
    container_state_times_and_inefficiency
group by
    jobid
