--1.6 Create MATERIALIZED VIEW 5m by device_family

CREATE MATERIALIZED VIEW nginx_5m_device_family
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,    
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)
LIMIT 100

  ----------+ The query users mv 
  SELECT
    device_family,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM nginx_5m_device_family
GROUP BY (device_family,timestamp,request_totals)
ORDER BY (timestamp,device_family)
LIMIT 100

--1.7 Create MATERIALIZED VIEW 30m by device_family

CREATE MATERIALIZED VIEW nginx_30m_device_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_family,timestamp)
AS SELECT
    device_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_5m_device_family
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (device_family,timestamp)
ORDER BY (device_family,timestamp)

  ----------+ The query users mv 
SELECT
    device_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_30m_device_family
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

--1.8 Create MATERIALIZED VIEW 1h by device_family
CREATE MATERIALIZED VIEW nginx_1h_device_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_family,timestamp)
AS SELECT
    device_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_30m_device_family
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (device_family,timestamp)
ORDER BY (device_family,timestamp)

  ----------+ The query users mv 
  SELECT
    device_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1h_device_family
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

--1.9 Create MATERIALIZED VIEW 1d by device_family

CREATE MATERIALIZED VIEW nginx_1d_device_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (device_family,timestamp)
AS SELECT
    device_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_1h_device_family
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (device_family,timestamp)
ORDER BY (device_family,timestamp)

  ----------+ The query users mv 
    SELECT
    device_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1d_device_family
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

--1.10 Create MATERIALIZED VIEW 5m by device_brand
CREATE MATERIALIZED VIEW nginx_5m_device_brand
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_brand,timestamp)
AS SELECT
    DISTINCT device_brand                           AS device_brand, 
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_brand,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,     
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

  ----------+ The query users mv 
  SELECT
    device_brand,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM nginx_5m_device_brand
GROUP BY (device_brand,timestamp,request_totals)
ORDER BY (timestamp,device_brand)

--1.11 Create MATERIALIZED VIEW 30m by device_brand
CREATE MATERIALIZED VIEW nginx_30m_device_brand
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_brand,timestamp)
AS SELECT
    device_brand,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_5m_device_brand
ORDER BY (timestamp,device_brand)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_brand,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (device_brand,timestamp)
ORDER BY (device_brand,timestamp)

  ----------+ The query users mv 
SELECT
    device_brand,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_30m_device_brand
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

--1.12 Create MATERIALIZED VIEW 1h by device_brand
CREATE MATERIALIZED VIEW nginx_1h_device_brand
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_brand,timestamp)
AS SELECT
    device_brand,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_30m_device_brand
ORDER BY (timestamp,device_brand)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_brand,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (device_brand,timestamp)
ORDER BY (device_brand,timestamp)

  ----------+ The query users mv 
SELECT
    device_brand,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1h_device_brand
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

--1.13 Create MATERIALIZED VIEW 1d by device_brand
CREATE MATERIALIZED VIEW nginx_1d_device_brand
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (device_brand,timestamp)
AS SELECT
    device_brand,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_1h_device_brand
ORDER BY (timestamp,device_brand)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_brand,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (device_brand,timestamp)
ORDER BY (device_brand,timestamp)

  ----------+ The query users mv 
SELECT
    device_brand,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1d_device_brand
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

--1.14 Create MATERIALIZED VIEW 5m by device_model
CREATE MATERIALIZED VIEW nginx_5m_device_model
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_model,timestamp)
AS SELECT
    DISTINCT device_model                           AS device_model, 
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_model,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,     
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

  ----------+ The query users mv 
  SELECT
    device_model,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM nginx_5m_device_model
GROUP BY (device_model,timestamp,request_totals)
ORDER BY (timestamp,device_model)

--1.15 Create MATERIALIZED VIEW 30m by device_model
CREATE MATERIALIZED VIEW nginx_30m_device_model
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_model,timestamp)
AS SELECT
    device_model,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_5m_device_model
ORDER BY (timestamp,device_model)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_model,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (device_model,timestamp)
ORDER BY (device_model,timestamp)

  ----------+ The query users mv 
SELECT
    device_model,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_30m_device_model
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

--1.16 Create MATERIALIZED VIEW 1h by device_model
CREATE MATERIALIZED VIEW nginx_1h_device_model
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_model,timestamp)
AS SELECT
    device_model,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_30m_device_model
ORDER BY (timestamp,device_model)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_model,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (device_model,timestamp)
ORDER BY (device_model,timestamp)

  ----------+ The query users mv 
SELECT
    device_model,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1h_device_model
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

--1.17 Create MATERIALIZED VIEW 1d by device_model
CREATE MATERIALIZED VIEW nginx_1d_device_model
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (device_model,timestamp)
AS SELECT
    device_model,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_1h_device_model
ORDER BY (timestamp,device_model)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_model,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (device_model,timestamp)
ORDER BY (device_model,timestamp)

  ----------+ The query users mv 
SELECT
    device_model,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1d_device_model
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

---------------------------------------------------------

--PART 2: VARNISH CACHE
--1.6 Create MATERIALIZED VIEW 5m by device_family

CREATE MATERIALIZED VIEW varnish_5m_device_family
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    uniq(client_ip)                                 AS client_ip_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,    
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)
LIMIT 100

  ----------+ The query users mv 
  SELECT
    device_family,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM varnish_5m_device_family
GROUP BY (device_family,timestamp,request_totals)
ORDER BY (timestamp,device_family)
LIMIT 100

--1.7 Create MATERIALIZED VIEW 30m by device_family

CREATE MATERIALIZED VIEW varnish_30m_device_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_family,timestamp)
AS SELECT
    device_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_5m_device_family
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM varnish_cache
GROUP BY (device_family,timestamp)
ORDER BY (device_family,timestamp)

  ----------+ The query users mv 
SELECT
    device_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_30m_device_family
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

--1.8 Create MATERIALIZED VIEW 1h by device_family
CREATE MATERIALIZED VIEW varnish_1h_device_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_family,timestamp)
AS SELECT
    device_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_30m_device_family
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (device_family,timestamp)
ORDER BY (device_family,timestamp)

  ----------+ The query users mv 
  SELECT
    device_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1h_device_family
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

--1.9 Create MATERIALIZED VIEW 1d by device_family

CREATE MATERIALIZED VIEW varnish_1d_device_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (device_family,timestamp)
AS SELECT
    device_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_1h_device_family
ORDER BY (timestamp,device_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (device_family,timestamp)
ORDER BY (device_family,timestamp)

  ----------+ The query users mv 
    SELECT
    device_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1d_device_family
GROUP BY (device_family,timestamp)
ORDER BY (timestamp,device_family)

--1.10 Create MATERIALIZED VIEW 5m by device_brand
CREATE MATERIALIZED VIEW varnish_5m_device_brand
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_brand,timestamp)
AS SELECT
    DISTINCT device_brand                           AS device_brand, 
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    uniq(client_ip)                                 AS client_ip_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_brand,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,     
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

  ----------+ The query users mv 
  SELECT
    device_brand,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM varnish_5m_device_brand
GROUP BY (device_brand,timestamp,request_totals)
ORDER BY (timestamp,device_brand)

--1.11 Create MATERIALIZED VIEW 30m by device_brand
CREATE MATERIALIZED VIEW varnish_30m_device_brand
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_brand,timestamp)
AS SELECT
    device_brand,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_5m_device_brand
ORDER BY (timestamp,device_brand)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_brand,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM varnish_cache
GROUP BY (device_brand,timestamp)
ORDER BY (device_brand,timestamp)

  ----------+ The query users mv 
SELECT
    device_brand,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_30m_device_brand
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

--1.12 Create MATERIALIZED VIEW 1h by device_brand
CREATE MATERIALIZED VIEW varnish_1h_device_brand
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_brand,timestamp)
AS SELECT
    device_brand,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_30m_device_brand
ORDER BY (timestamp,device_brand)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_brand,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (device_brand,timestamp)
ORDER BY (device_brand,timestamp)

  ----------+ The query users mv 
SELECT
    device_brand,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1h_device_brand
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

--1.13 Create MATERIALIZED VIEW 1d by device_brand
CREATE MATERIALIZED VIEW varnish_1d_device_brand
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (device_brand,timestamp)
AS SELECT
    device_brand,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_1h_device_brand
ORDER BY (timestamp,device_brand)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_brand,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (device_brand,timestamp)
ORDER BY (device_brand,timestamp)

  ----------+ The query users mv 
SELECT
    device_brand,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1d_device_brand
GROUP BY (device_brand,timestamp)
ORDER BY (timestamp,device_brand)

--1.14 Create MATERIALIZED VIEW 5m by device_model
CREATE MATERIALIZED VIEW varnish_5m_device_model
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_model,timestamp)
AS SELECT
    DISTINCT device_model                           AS device_model, 
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    uniq(client_ip)                                 AS client_ip_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_model,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,     
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

  ----------+ The query users mv 
  SELECT
    device_model,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM varnish_5m_device_model
GROUP BY (device_model,timestamp,request_totals)
ORDER BY (timestamp,device_model)

--1.15 Create MATERIALIZED VIEW 30m by device_model
CREATE MATERIALIZED VIEW varnish_30m_device_model
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_model,timestamp)
AS SELECT
    device_model,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_5m_device_model
ORDER BY (timestamp,device_model)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_model,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM varnish_cache
GROUP BY (device_model,timestamp)
ORDER BY (device_model,timestamp)

  ----------+ The query users mv 
SELECT
    device_model,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_30m_device_model
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

--1.16 Create MATERIALIZED VIEW 1h by device_model
CREATE MATERIALIZED VIEW varnish_1h_device_model
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (device_model,timestamp)
AS SELECT
    device_model,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_30m_device_model
ORDER BY (timestamp,device_model)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_model,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM varnish_cache
GROUP BY (device_model,timestamp)
ORDER BY (device_model,timestamp)

  ----------+ The query users mv 
SELECT
    device_model,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1h_device_model
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)

--1.17 Create MATERIALIZED VIEW 1d by device_model
CREATE MATERIALIZED VIEW varnish_1d_device_model
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (device_model,timestamp)
AS SELECT
    device_model,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_1h_device_model
ORDER BY (timestamp,device_model)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT device_model,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM varnish_cache
GROUP BY (device_model,timestamp)
ORDER BY (device_model,timestamp)

  ----------+ The query users mv 
SELECT
    device_model,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1d_device_model
GROUP BY (device_model,timestamp)
ORDER BY (timestamp,device_model)