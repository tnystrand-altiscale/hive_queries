#!/bin/bash
log_name="$0_log.txt"

hive -e "

use thomas_test;

drop table if exists capacity_combined;

create table
    capacity_combined
stored as
    orc
as select
    queue_date,
    queue_system,
    queue_name,
    avg(capacity) as capacity,
    avg(max_capacity) as max_capacity,
    avg(cluster_memory_capacity) as cluster_memory_capacity,
    avg(cluster_vcore_capacity) as cluster_vcore_capacity,
    avg(cluster_hdfs_capacity) as cluster_hdfs_capacity
from
    cluster_metrics_prod_1.queue_dim,
    cluster_metrics_prod_1.cluster_resource_dim
where
    cluster_system=queue_system and
    cluster_date=queue_date and
    cluster_date>='2015-05-08' and
    cluster_date<='2015-05-17'
group by
    queue_date,
    queue_system,
    queue_name
"
