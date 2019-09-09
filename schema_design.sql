--Create database--
CREATE DATABASE cdn_log
--Part 1: nginx access datas
--1.1 create TABLE
CREATE TABLE nginx_access_without_geoip
 (
  time_write_log DateTime,
  client_ip String,
  method String,
  url String,
  uri String,
  response UInt32,
  bytes UInt32,
  referer String,
  user_agent String,
  http_x_forwarded_for String,
  hitmiss String,
  request_time Float32,
  hostname String,
  response_upstream String,
  request_time_upstream String,
  browser_family Nullable(String),
  browser_version Nullable(String),
  os_family Nullable(String),
  os_version Nullable(String),
  device_family Nullable(String),
  device_brand Nullable(String),
  device_model Nullable(String)
 )
 ENGINE = MergeTree()
 PARTITION BY toYYYYMM(time_write_log)
 ORDER BY (time_write_log,client_ip)

 --1.2 create TABLE that have been enriched geometry IP
 CREATE MATERIALIZED VIEW nginx_access
    ENGINE = MergeTree()
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (timestamp,client_ip)
    AS SELECT
        nginx_access_without_geoip.time_write_log AS timestamp,
        client_ip,
        method,
        url,
        uri,
        response as status,
        bytes,
        referer,
        user_agent,
        http_x_forwarded_for,
        hitmiss,
        request_time,
        hostname,
        response_upstream AS status_ups,
        request_time_upstream AS request_time_ups,
        browser_family,
        browser_version,
        os_family,
        os_version,
        device_family,
        device_brand,
        device_model,
        dictGetUInt32('geoip_city_blocks_ipv4', 'geoname_id', tuple(IPv4StringToNum(client_ip))) AS geoname_id,
        dictGetString('geoip_city_locations_en', 'country_name', toUInt64(geoname_id)) AS country, 
        dictGetString('geoip_city_locations_en', 'subdivision_1_name', toUInt64(geoname_id)) AS city
    FROM 
    cdn_log.nginx_access_without_geoip
--1.3 Create MATERIALIZED VIEW by 5m
CREATE MATERIALIZED VIEW nginx_5m
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    uniqState(client_ip) clientip_totals,
    uniqState(status) as status_totals,
    sumState(bytes) as byte_totals,
    uniqState(hitmiss) AS hitmiss_totals,
    sumState(request_time) as request_time_totals,
    uniqState(browser_family) AS browser_family_totals,
    uniqState(browser_version) AS browser_version_totals ,
    uniqState(os_family) AS os_family_totals,
    uniqState(os_version) AS os_version_totals,
    uniqState(device_family) AS device_family_totals,
    uniqState(device_brand) AS device_brand_totals,
    uniqState(device_model) AS device_model_totals,
    uniqState(country) AS country_totals,
    uniqState(city) as city_totals
FROM nginx_access
GROUP BY timestamp
ORDER BY timestamp
---- driver:
----------+ The query does not use mv (materialized view)
SELECT 
     toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
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
    city_totals
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
    city_totals
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
    city_totals
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

--1.6 Create MATERIALIZED VIEW 5m by device_family

CREATE MATERIALIZED VIEW nginx_5m_devie_family
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sumState(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)
LIMIT 100

  ----------+ The query users mv 
  SELECT
    device_family,
    timestamp,
    sumMerge(bytes_totals) AS bytes_totals,
    request_totals
FROM nginx_5m_devie_family
GROUP BY (device_family,timestamp,request_totals)
ORDER BY (timestamp,device_family)
LIMIT 100