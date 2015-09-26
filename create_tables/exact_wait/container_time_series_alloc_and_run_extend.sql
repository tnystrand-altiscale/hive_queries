set SERIES_TABLE=eric_cluster_metrics_dev_4.container_time_series;
set FACT_TABLE=eric_cluster_metrics_dev_4.container_fact;

use eric_cluster_metrics_dev_4;

-- Changes to container_time_series
-- Vcore-smoothed
-- regular vcore kept
-- waitingtime unaggregated (floating point)
-- Column for minute when container was first requested

-- Need container_time_series with ALL the containers

drop table if exists container_time_series_alloc_and_run_extend;

create table
    container_time_series_alloc_and_run_extend (
		container_wait_time                 bigint,
		memory                              double,
		container_size                      int,
		cluster_memory                      bigint,
		minute_start                        int,
		job_id                              string,
		queue                               string,
		container_id                        string,
		state                               string,
		measure_date                        string,
		account                             int,
		cluster_uuid                        string,
		principal_uuid                      string,
		user_key                            string,
		vcores                              double,
		container_vcores                    int,
		number_apps                         bigint,
		host                                string,
		requestedtime                       bigint,
        allocatedtime                       bigint,
		acquiredtime                        bigint,
        runningtime                         bigint,
        reservedtime                        bigint,
		requestedtime_minute                bigint,
		container_wait_time_unagg           bigint,
		container_wait_time_unagg_exact     double
	)
partitioned by (
	system string,
	date string
	)
stored as
	orc;

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

insert overwrite table container_time_series_alloc_and_run_extend
partition(system,date)
SELECT
	cts.container_wait_time,
	cts.memory,
    cf.memory as container_size,
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
	cts.vcores as container_vcores,
	cts.number_apps,
	cts.host,
	cf.requestedtime,
    cf.allocatedtime,
	cf.acquiredtime,
    cf.runningtime,
    cf.reservedtime,
	floor(cf.requestedtime/60000)*60 as requestedtime_minute,
	if(cts.state='REQUESTED',
        if(floor(cf.requestedtime/60000)*60=cts.minute_start,
		    cts.container_wait_time,
		    cts.container_wait_time
		    +floor(cf.requestedtime/1000)
		    -cts.minute_start),
        0
	) AS container_wait_time_unagg,
	if(cts.state='REQUESTED',
        case
            when (cf.requestedtime/1000 <= minute_start and cf.allocatedtime/1000 >= minute_start+60) then
                60
            when (cf.requestedtime/1000 <= minute_start and cf.allocatedtime/1000 <  minute_start+60) then
                cf.allocatedtime/1000-minute_start
            when (cf.requestedtime/1000 >  minute_start and cf.allocatedtime/1000 >= minute_start+60) then
                minute_start+60-cf.requestedtime/1000
            when (cf.requestedtime/1000 >  minute_start and cf.allocatedtime/1000 <  minute_start+60 and cf.allocatedtime/1000>0) then
                (cf.allocatedtime-cf.requestedtime)/1000
            else
                0
        end,
        0
	) AS container_wait_time_unagg_exact,
	cts.system,
	cts.date
FROM
	${hiveconf:SERIES_TABLE} as cts,
	${hiveconf:FACT_TABLE} as cf
WHERE
	cts.container_id    = cf.containerid and
	cts.system          = cf.system


