select
    count(distinct(job_id))
from
    eric_cluster_metrics_dev_5.container_time_series as cts
where
    cts.container_wait_time > 30 and
    cts.date        = '2015-07-13'
