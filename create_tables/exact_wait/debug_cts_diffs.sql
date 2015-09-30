select new.*,old.* from
(
select * from eric_cluster_metrics_dev_4.container_time_series
where minute_start=1436796000 and system='iheartradio' and date='2015-07-13'
) as new
full outer join
(
select * from cluster_metrics_prod_1.container_time_series 
where minute_start=1436796000 and system='iheartradio' and date='2015-07-13'
) as old
on
new.minute_start=old.minute_start
and new.job_id=old.job_id
and new.state=old.state
and new.system=old.system
