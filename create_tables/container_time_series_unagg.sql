USE eric_cluster_metrics_dev_4;

DROP TABLE IF EXISTS container_time_series_unagg;

CREATE TABLE container_time_series_unagg STORED AS ORC AS

WITH
container_starts AS (
 SELECT min(minute_start) AS container_start, container_id FROM container_time_series GROUP BY container_id
)
SELECT 
SUM((container_wait_time - (minute_start - container_start))) AS container_wait_time, 
SUM(memory) AS memory,
SUM(cluster_memory) AS cluster_memory,
SUM(minute_start) AS minute_start,
MIN(queue) AS queue,
MIN(container_time_series.container_id) AS container_id,
MIN(job_id) AS job_id,
MIN(state) AS state,
MIN(measure_date) AS measure_date,
MIN(account) AS account,
MIN(cluster_uuid) AS cluster_uuid,
MIN(principal_uuid) AS principal_uuid,
MIN(user_key) AS user_key,
SUM(vcores) AS vcores,
MIN(number_apps) AS number_apps,
MIN(host) AS host,
MIN(system) AS system,
MIN(date) AS date
FROM container_time_series, container_starts
WHERE container_time_series.container_id = container_starts.container_id
GROUP BY container_time_series.container_id, minute_start, container_starts.container_start;
