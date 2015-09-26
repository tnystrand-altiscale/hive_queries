
select 
    minute_start,
    state,
    count(*)
from 
    eric_cluster_metrics_dev_4.container_time_series
where
    job_id='job_1435714271812_17489'
    and date='2015-07-13'
group by
    state,
    minute_start
