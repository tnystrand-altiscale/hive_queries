use thomas_test;

DROP TABLE IF EXISTS cluster_sec_waiting_container_stats;

CREATE table
    cluster_sec_waiting_container_stats
stored as
    ORC
as select
    minute_start,
    system,
    min(measure_date) as measure_date,
    sum(number_waiting_containers_job) as number_waiting_containers_cluster,
    sum(jsr.memory_of_waiting_containers_job) as memory_of_waiting_containers_cluster,
    sum(jsr.vcore_of_waiting_containers_job) as vcore_of_waiting_containers_cluster
from
    thomas_test.job_sec_waiting_container_stats as jsr
GROUP by
    minute_start,
    system
