USE eric_cluster_metrics_dev_4;

drop table if exists container_time_series_vhacked_with_unagg;

create table
	container_time_series_vhacked_with_unagg (
		container_wait_time         bigint,
		memory                      double,
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
		number_apps                 bigint,
		host                        string,
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

insert overwrite table container_time_series_vhacked_with_unagg
partition(system,date)
SELECT
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
	cts.container_wait_time - (cts.minute_start - cs.container_start) AS container_wait_time_unagg,
	cts.host,
	cts.system,
	cts.date
FROM
	container_time_series as cts,
	container_fact as cf,
	(
	SELECT
		container_id,
		system,
		min(minute_start) AS container_start
	FROM
		container_time_series
	GROUP BY
		container_id,
		system
	) as cs
WHERE
	cts.container_id 	= cs.container_id and
	cts.system 		= cs.system and
	cts.container_id 	= cf.containerid and
	cts.system 		= cf.system


