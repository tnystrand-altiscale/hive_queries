USE eric_cluster_metrics_dev_4;

drop table if exists container_time_series_alloc_and_run_extend;

create table
    container_time_series_alloc_and_run_extend (
		container_wait_time         bigint,
		memory                      double,
		container_size              int,
		cluster_memory              bigint,
		minute_start                int,
		job_id                      string,
		queue                       string,
		container_id                string,
		state                       string,
		measure_date                string,
		account                     int,
		cluster_uuid                string,
		principal_uuid              string,
		user_key                    string,
		vcores                      double,
		container_vcores            int,
		number_apps                 bigint,
		host                        string,
		requestedtime               bigint,
        allocatedtime               bigint,
		acquiredtime                bigint,
        runningtime                 bigint,
		requestedtime_minute        bigint,
		container_wait_time_unagg   bigint
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
	floor(cf.requestedtime/60000)*60 as requestedtime_minute,
	if(cts.state='REQUESTED',
        if(floor(cf.requestedtime/60000)*60=cts.minute_start,
		    cts.container_wait_time,
		    cts.container_wait_time
		    +floor(cf.requestedtime/1000)
		    -cts.minute_start),
        0
	) AS container_wait_time_unagg,
	cts.system,
	cts.date
FROM
	container_time_series as cts,
	container_fact as cf
WHERE
	cts.container_id = cf.containerid and
	cts.system 		 = cf.system


