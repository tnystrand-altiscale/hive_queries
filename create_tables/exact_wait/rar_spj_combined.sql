use thomas_test;

drop table if exists rar_spj_combined;

create table rar_spj_combined
as select
    rar.minute_start as rar_minute_start,
    rar.timestamp, 
    rar.jobid,
    rar.memory,
    rar.action,
    rar.system as rar_system,
    rar.date as rar_date,
    spj.*
from
    request_assign_release as rar
full outer join
    state_perminute_job as spj
on (
   rar.minute_start=spj.minute_start and
   rar.jobid = spj.job_id and
   rar.system = spj.system
)
where
    rar.system='iheartradio'
    and spj.system='iheartradio'
    and (rar.minute_start is null or spj.minute_start is null)
