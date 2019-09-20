--Part1 : nginx access datas
--1.3 Create MATERIALIZED VIEW by 5m

CREATE MATERIALIZED VIEW nginx_5m
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,

    uniqState(client_ip)                            AS clientip_totals,
    uniqState(status)                               AS status_totals,
    sumState(bytes)                                 AS byte_totals,
    uniqState(hitmiss)                              AS hitmiss_totals,

    sumState(request_time)                          AS request_time_totals,
    uniqState(browser_family)                       AS browser_family_totals,
    uniqState(browser_version)                      AS browser_version_totals ,
    uniqState(os_family)                            AS os_family_totals,
    uniqState(os_version)                           AS os_version_totals,
    uniqState(device_family)                        AS device_family_totals,
    uniqState(device_brand)                         AS device_brand_totals,
    uniqState(device_model)                         AS device_model_totals,

    uniqState(country)                              AS country_totals,
    uniqState(city)                                 AS city_totals,

    uniqState(channel)                              AS channel_totals,

    count()                                         AS request_totals
    
FROM nginx_access
GROUP BY timestamp
ORDER BY timestamp

---- driver:
----------+ The query does not use mv (materialized view)
SELECT 
     toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
     uniq(client_ip)                                 AS clientip_totals,
     sum(bytes)                                      AS byte_totals,
     uniq(hitmiss)                                   AS hitmit_totals,
     sum(request_time)                               AS request_time_totals
FROM
 nginx_access
 GROUP BY timestamp
 ORDER BY timestamp
----------+ The query users mv 
 SELECT 
    timestamp,
    uniqMerge(clientip_totals)                       AS clientip_totals,
    sumMerge(byte_totals)                            AS byte_totals,
    uniqMerge(hitmiss_totals)                        AS hitmiss_totals,
    sumMerge(request_time_totals)                    AS request_time_totals
FROM nginx_5m
GROUP BY timestamp
ORDER  BY timestamp

--1.4 Create MATERIALIZED VIEW by 30m
CREATE MATERIALIZED VIEW nginx_30m
    ENGINE = SummingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,

    clientip_totals,
    status_totals,
    byte_totals,
    hitmiss_totals,
    request_time_totals,

    browser_family_totals,
    browser_version_totals ,
    os_family_totals,
    os_version_totals,
    device_family_totals,
    device_brand_totals,
    device_model_totals,

    country_totals,
    city_totals,

    channel_totals,

    request_totals
FROM nginx_5m
ORDER BY timestamp
----driver:
-----------+The query does not use mv
SELECT
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    uniq(client_ip),
    uniq(status),
    sum(request_time)
FROM nginx_access
GROUP BY timestamp
ORDER BY timestamp
----------+ The query users mv 
SELECT
    timestamp,
    uniqMerge(clientip_totals) clientip_totals,
    uniqMerge(status_totals) status_totals,
    sumMerge(request_time_totals)
FROM nginx_30m 
GROUP BY timestamp
ORDER BY timestamp
--1.5 Create MATERIALIZED VIEW by 1h
CREATE MATERIALIZED VIEW nginx_1h
    ENGINE = SummingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,

    clientip_totals,
    status_totals,
    byte_totals,
    hitmiss_totals,
    request_time_totals,

    browser_family_totals,
    browser_version_totals,
    os_family_totals,
    os_version_totals,
    device_family_totals,
    device_brand_totals,
    device_model_totals,

    country_totals,
    city_totals,

    channel_totals,

    request_totals
FROM nginx_30m
ORDER BY timestamp
----driver:
-----------+The query does not use mv
SELECT 
     toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
     uniq(client_ip),
     sum(bytes),
     uniq(hitmiss),
     sum(request_time)
FROM
 nginx_access
 GROUP BY timestamp
 ORDER BY timestamp
 ----------+ The query users mv 
  SELECT 
    timestamp,
    uniqMerge(clientip_totals),
    sumMerge(byte_totals),
    uniqMerge(hitmiss_totals),
    sumMerge(request_time_totals)
FROM nginx_1h
GROUP BY timestamp
ORDER  BY timestamp

--1.5 Create MATERIALIZED VIEW by 1d
CREATE MATERIALIZED VIEW nginx_1d
    ENGINE = SummingMergeTree()
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,

    clientip_totals,
    status_totals,
    byte_totals,
    hitmiss_totals,
    request_time_totals,

    browser_family_totals,
    browser_version_totals,
    os_family_totals,
    os_version_totals,
    device_family_totals,
    device_brand_totals,
    device_model_totals,

    country_totals,
    city_totals,

    channel_totals,

    request_totals
FROM nginx_1h
ORDER BY timestamp
----driver:
-----------+The query does not use mv
SELECT 
     toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
     uniq(client_ip),
     sum(bytes),
     uniq(hitmiss),
     sum(request_time)
FROM
 nginx_access
 GROUP BY timestamp
 ORDER BY timestamp
  ----------+ The query users mv 
  SELECT 
    timestamp,
    uniqMerge(clientip_totals),
    sumMerge(byte_totals),
    uniqMerge(hitmiss_totals),
    sumMerge(request_time_totals)
FROM nginx_1d
GROUP BY timestamp
ORDER  BY timestamp

----------------------------------------------------------------------------------------------

--Part2 : varnish cache datas
--2.3 Create MATERIALIZED VIEW by 5m

CREATE MATERIALIZED VIEW varnish_5m
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,

    uniqState(host)                                 AS host_totals,
    uniqState(client_ip)                            AS clientip_totals,
    uniqState(request_line)                         AS request_line_totals,
    uniqState(status)                               AS status_totals,
    sumState(bytes)                                 AS byte_totals,
    uniqState(hitmiss)                              AS hitmiss_totals,
    sumState(bytes_sent_client)                     AS bytes_sent_client_totals,
    sumState(request_time_tmp)                      AS request_time_tmp_totals,
    sumState(varnish_time_firstbyte)                AS varnish_time_firstbyte_totals,
    
    uniqState(browser_family)                       AS browser_family_totals,
    uniqState(browser_version)                      AS browser_version_totals ,
    uniqState(os_family)                            AS os_family_totals,
    uniqState(os_version)                           AS os_version_totals,
    uniqState(device_family)                        AS device_family_totals,
    uniqState(device_brand)                         AS device_brand_totals,
    uniqState(device_model)                         AS device_model_totals,

    uniqState(country)                              AS country_totals,
    uniqState(city)                                 AS city_totals,

    uniqState(channel)                              AS channel_totals,

    count()                                         AS request_totals
    
FROM vanish_cache
GROUP BY timestamp
ORDER BY timestamp

---- driver:
----------+ The query does not use mv (materialized view)
SELECT 
     toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
     uniq(client_ip)                                 AS clientip_totals,
     sum(bytes)                                      AS byte_totals,
     uniq(hitmiss)                                   AS hitmit_totals
FROM
 varnish_cache
 GROUP BY timestamp
 ORDER BY timestamp
----------+ The query users mv 
 SELECT 
    timestamp,
    uniqMerge(clientip_totals)                       AS clientip_totals,
    sumMerge(byte_totals)                            AS byte_totals,
    uniqMerge(hitmiss_totals)                        AS hitmiss_totals
FROM varnish_5m
GROUP BY timestamp
ORDER  BY timestamp

--1.4 Create MATERIALIZED VIEW by 30m
CREATE MATERIALIZED VIEW varnish_30m
    ENGINE = SummingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,

    host_totals,
    clientip_totals,
    request_line_totals,
    status_totals,
    byte_totals,
    hitmiss_totals,
    bytes_sent_client_totals,
    request_time_tmp_totals,
    varnish_time_firstbyte_totals,
    
    browser_family_totals,
    browser_version_totals ,
    os_family_totals,
    os_version_totals,
    device_family_totals,
    device_brand_totals,
    device_model_totals,

    country_totals,
    city_totals,

    channel_totals,

    request_totals
FROM varnish_5m
ORDER BY timestamp
----driver:
-----------+The query does not use mv
SELECT
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    uniq(client_ip),
    uniq(status)
FROM varnish_cache
GROUP BY timestamp
ORDER BY timestamp
----------+ The query users mv 
SELECT
    timestamp,
    uniqMerge(clientip_totals) clientip_totals,
    uniqMerge(status_totals) status_totals
FROM varnish_30m 
GROUP BY timestamp
ORDER BY timestamp
--1.5 Create MATERIALIZED VIEW by 1h
CREATE MATERIALIZED VIEW varnish_1h
    ENGINE = SummingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,

    host_totals,
    clientip_totals,
    request_line_totals,
    status_totals,
    byte_totals,
    hitmiss_totals,
    bytes_sent_client_totals,
    request_time_tmp_totals,
    varnish_time_firstbyte_totals,
    
    browser_family_totals,
    browser_version_totals ,
    os_family_totals,
    os_version_totals,
    device_family_totals,
    device_brand_totals,
    device_model_totals,

    country_totals,
    city_totals,

    channel_totals,

    request_totals
FROM varnish_30m
ORDER BY timestamp
----driver:
-----------+The query does not use mv
SELECT 
     toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
     uniq(client_ip),
     sum(bytes),
     uniq(hitmiss)
    
FROM
 varnish_cache
 GROUP BY timestamp
 ORDER BY timestamp
 ----------+ The query users mv 
  SELECT 
    timestamp,
    uniqMerge(clientip_totals),
    sumMerge(byte_totals),
    uniqMerge(hitmiss_totals)
FROM varnish_1h
GROUP BY timestamp
ORDER  BY timestamp

--1.5 Create MATERIALIZED VIEW by 1d
CREATE MATERIALIZED VIEW varnish_1d
    ENGINE = SummingMergeTree()
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,

    host_totals,
    clientip_totals,
    request_line_totals,
    status_totals,
    byte_totals,
    hitmiss_totals,
    bytes_sent_client_totals,
    request_time_tmp_totals,
    varnish_time_firstbyte_totals,
    
    browser_family_totals,
    browser_version_totals ,
    os_family_totals,
    os_version_totals,
    device_family_totals,
    device_brand_totals,
    device_model_totals,

    country_totals,
    city_totals,

    channel_totals,

    request_totals
FROM varnish_1h
ORDER BY timestamp
----driver:
-----------+The query does not use mv
SELECT 
     toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
     uniq(client_ip),
     sum(bytes),
     uniq(hitmiss),
     sum(request_time)
FROM
 varnish_cache
 GROUP BY timestamp
 ORDER BY timestamp
  ----------+ The query users mv 
  SELECT 
    timestamp,
    uniqMerge(clientip_totals),
    sumMerge(byte_totals),
    uniqMerge(hitmiss_totals)
FROM varnish_1d
GROUP BY timestamp
ORDER  BY timestamp