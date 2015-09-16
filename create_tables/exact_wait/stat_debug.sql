

select
        job_id,
        minute_start,
        system,
        min(user_key) as user_key,
        min(measure_date) as measure_date,
        min(queue) as queue,
        -- What is taking up memory in the beginng of the minute?
        -- Filter for all containers that are at least allocated at beginning of minute
        -- Container time series does not show allocated or acquired states for small times
        -- This is a problem, since some memory will be sceduled before the minute, but not recorded
        -- after. This can be fixed if grouping by container_id's.
        -- For each running/allocated/acquired container, check if allocation time < minute_start
        sum(
            case when state='ALLOCATED' 
                    and allocatedtime<bigint(minute_start)*1000
                    then memory
                when state='ACQUIRED'
                    and acquiredtime<bigint(minute_start)*1000
                    then memory
                when state='RUNNING'
                    and runningtime<bigint(minute_start)*1000
                    then memory
            else 0 end) as memory_job,

        sum(
            case when state='ALLOCATED'
                    and allocatedtime<bigint(minute_start)*1000
                    then vcores 
                when state='ACQUIRED'
                    and acquiredtime<bigint(minute_start)*1000
                    then vcores
                when state='RUNNING'
                    and runningtime<bigint(minute_start)*1000
                    then vcores
            else 0 end) as vcores_job,
        -- What is waiting in the beginning of the minute?
        -- Some REQUESTED are missing from the container_time_series
        -- however this is unimportant since these are only <1 waiting sec.
        sum(if(state='REQUESTED'
               and requestedtime<bigint(minute_start)*1000,
               memory,0)) as memory_REQ_job,
        sum(if(state='REQUESTED'
               and requestedtime<bigint(minute_start)*1000,
               vcores,0)) as vcores_REQ_job
    from
        eric_cluster_metrics_dev_4.container_time_series_alloc_and_run_extend as cts
    where
        measure_date='2015-07-10'
        and job_id='job_1435714271812_10791'
    group by
        job_id,
        minute_start,
        system
