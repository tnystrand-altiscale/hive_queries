use eric_cluster_metrics_dev_4;

drop table if exists container_time_series_vhacked;

create table container_time_series_vhacked (
    container_wait_time 	bigint, 
    memory              	double,
    cluster_memory      	bigint,
    minute_start        	int,
    job_id              	string,
    queue  	                string,
    container_id        	string,
    state               	string,
    measure_date        	string,
    account             	int,
    cluster_uuid        	string,
    principal_uuid      	string,
    user_key            	string,
    vcores              	double,
    number_apps         	bigint,
    host                	string
)
partitioned by (system string, date string)
stored as orc;

SET hive.exec.dynamic.partition = true;

SET hive.exec.dynamic.partition.mode = nonstrict;

insert overwrite table container_time_series_vhacked
partition(system,date)
select
    cts.container_wait_time, 
    cts.memory,
    cts.cluster_memory,
    cts.minute_start,
    cts.job_id,
    cts.queue,
    cts.container_id,
    cts.state,
    cts.measure_date,
    cts.account,
    cts.cluster_uuid,
    cts.principal_uuid,
    cts.user_key,
    cts.memory/cf.memory*cts.vcores as vcores,
    cts.number_apps,
    cts.host,
    cts.system,
    cts.date
from
    container_fact as cf,
    container_time_series as cts
where
    cf.containerid=cts.container_id and
    cf.system=cts.system
