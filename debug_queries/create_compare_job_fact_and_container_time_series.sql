use thomas_test;

drop table if exists compare_job_fact_and_container_time_series;

create table compare_job_fact_and_container_time_series
as select
	cf.containerid,
	min(minute_start) as minute_start,
	min(if(container_wait_time>0,container_wait_time,999999999) as minute_start_container_wait_time,
	
	
	
	
from
	eric_cluster_metrics_dev_4.container_time_series as cts,
	eric_cluster_metrics_dev_4.container_fact as cf
where
	cf.containerid=cts.container_id and
	cf.system=cts.system
group by
	cts.container_id
