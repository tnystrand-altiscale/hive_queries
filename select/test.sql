select
    count(distinct(cts.job_id))
from
    thomas_test.job_min_with_queue_lim as js,
    eric_cluster_metrics_dev_5.container_time_series as cts
where
    cts.date        = '2015-07-13' and
    --(cts.state = 'REQUESTED' or cts.state='EXPIRED') and
    js.job_id       = cts.job_id        and
    js.date         = cts.date          and
    js.system       = cts.system
