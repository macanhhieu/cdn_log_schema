--1.6 Create MATERIALIZED VIEW 5m by os_family

CREATE MATERIALIZED VIEW nginx_5m_os_family
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,    
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)
LIMIT 100

  ----------+ The query users mv 
  SELECT
    os_family,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM nginx_5m_os_family
GROUP BY (os_family,timestamp,request_totals)
ORDER BY (timestamp,os_family)
LIMIT 100

--1.7 Create MATERIALIZED VIEW 30m by os_family

CREATE MATERIALIZED VIEW nginx_30m_os_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_family,timestamp)
AS SELECT
    os_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_5m_os_family
ORDER BY (timestamp,os_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (os_family,timestamp)
ORDER BY (device_family,os_family)

  ----------+ The query users mv 
SELECT
    os_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_30m_os_family
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)

--1.8 Create MATERIALIZED VIEW 1h by os_family
CREATE MATERIALIZED VIEW nginx_1h_os_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_family,timestamp)
AS SELECT
    os_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_30m_os_family
ORDER BY (timestamp,os_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (os_family,timestamp)
ORDER BY (os_family,timestamp)

  ----------+ The query users mv 
  SELECT
    os_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1h_os_family
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)

--1.9 Create MATERIALIZED VIEW 1d by os_family

CREATE MATERIALIZED VIEW nginx_1d_os_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (os_family,timestamp)
AS SELECT
    os_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_1h_os_family
ORDER BY (timestamp,os_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (os_family,timestamp)
ORDER BY (os_family,timestamp)

  ----------+ The query users mv 
    SELECT
    os_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1d_os_family
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)

--1.10 Create MATERIALIZED VIEW 5m by os_version
CREATE MATERIALIZED VIEW nginx_5m_os_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_version,timestamp)
AS SELECT
    DISTINCT os_version                             AS os_version, 
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_version,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,     
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)

  ----------+ The query users mv 
  SELECT
    os_version,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM nginx_5m_os_version
GROUP BY (os_version,timestamp,request_totals)
ORDER BY (timestamp,os_version)

--1.11 Create MATERIALIZED VIEW 30m by os_version
CREATE MATERIALIZED VIEW nginx_30m_os_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_version,timestamp)
AS SELECT
    os_version,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_5m_os_version
ORDER BY (timestamp,os_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_version,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    sum(bytes)                                       AS bytes_totals,
    count()                                          AS request_totals
FROM nginx_access
GROUP BY (os_version,timestamp)
ORDER BY (os_version,timestamp)

  ----------+ The query users mv 
SELECT
    os_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_30m_os_version
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)

--1.12 Create MATERIALIZED VIEW 1h by os_version
CREATE MATERIALIZED VIEW nginx_1h_os_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_version,timestamp)
AS SELECT
    os_version,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_30m_os_version
ORDER BY (timestamp,os_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_version,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (os_version,timestamp)
ORDER BY (os_version,timestamp)

  ----------+ The query users mv 
SELECT
    os_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1h_os_version
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)

--1.13 Create MATERIALIZED VIEW 1d by os_version
CREATE MATERIALIZED VIEW nginx_1d_os_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (os_version,timestamp)
AS SELECT
    os_version,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_1h_os_version
ORDER BY (timestamp,os_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_version,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (os_version,timestamp)
ORDER BY (os_version,timestamp)

  ----------+ The query users mv 
SELECT
    os_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1d_os_version
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)


---------------------------------------------------------------------------
--PART 2 : VARNISH CACHE DATAS 
--1.6 Create MATERIALIZED VIEW 5m by os_family

CREATE MATERIALIZED VIEW varnish_5m_os_family
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    uniq(client_ip)                                 AS client_ip_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,    
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)
LIMIT 100

  ----------+ The query users mv 
  SELECT
    os_family,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM varnish_5m_os_family
GROUP BY (os_family,timestamp,request_totals)
ORDER BY (timestamp,os_family)
LIMIT 100

--1.7 Create MATERIALIZED VIEW 30m by os_family

CREATE MATERIALIZED VIEW varnish_30m_os_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_family,timestamp)
AS SELECT
    os_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_5m_os_family
ORDER BY (timestamp,os_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM varnish_cache
GROUP BY (os_family,timestamp)
ORDER BY (device_family,os_family)

  ----------+ The query users mv 
SELECT
    os_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_30m_os_family
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)

--1.8 Create MATERIALIZED VIEW 1h by os_family
CREATE MATERIALIZED VIEW varnish_1h_os_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_family,timestamp)
AS SELECT
    os_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_30m_os_family
ORDER BY (timestamp,os_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (os_family,timestamp)
ORDER BY (os_family,timestamp)

  ----------+ The query users mv 
  SELECT
    os_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1h_os_family
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)

--1.9 Create MATERIALIZED VIEW 1d by os_family

CREATE MATERIALIZED VIEW varnish_1d_os_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (os_family,timestamp)
AS SELECT
    os_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_1h_os_family
ORDER BY (timestamp,os_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (os_family,timestamp)
ORDER BY (os_family,timestamp)

  ----------+ The query users mv 
    SELECT
    os_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1d_os_family
GROUP BY (os_family,timestamp)
ORDER BY (timestamp,os_family)

--1.10 Create MATERIALIZED VIEW 5m by os_version
CREATE MATERIALIZED VIEW varnish_5m_os_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_version,timestamp)
AS SELECT
    DISTINCT os_version                             AS os_version, 
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    uniq(client_ip)                                 AS client_ip_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_version,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,     
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)

  ----------+ The query users mv 
  SELECT
    os_version,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM varnish_5m_os_version
GROUP BY (os_version,timestamp,request_totals)
ORDER BY (timestamp,os_version)

--1.11 Create MATERIALIZED VIEW 30m by os_version
CREATE MATERIALIZED VIEW varnish_30m_os_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_version,timestamp)
AS SELECT
    os_version,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_5m_os_version
ORDER BY (timestamp,os_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_version,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    sum(bytes)                                       AS bytes_totals,
    count()                                          AS request_totals
FROM varnish_cache
GROUP BY (os_version,timestamp)
ORDER BY (os_version,timestamp)

  ----------+ The query users mv 
SELECT
    os_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_30m_os_version
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)

--1.12 Create MATERIALIZED VIEW 1h by os_version
CREATE MATERIALIZED VIEW varnish_1h_os_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (os_version,timestamp)
AS SELECT
    os_version,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_30m_os_version
ORDER BY (timestamp,os_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_version,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (os_version,timestamp)
ORDER BY (os_version,timestamp)

  ----------+ The query users mv 
SELECT
    os_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1h_os_version
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)

--1.13 Create MATERIALIZED VIEW 1d by os_version
CREATE MATERIALIZED VIEW varnish_1d_os_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (os_version,timestamp)
AS SELECT
    os_version,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    client_ip_totals,
    request_totals
FROM varnish_1h_os_version
ORDER BY (timestamp,os_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT os_version,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (os_version,timestamp)
ORDER BY (os_version,timestamp)

  ----------+ The query users mv 
SELECT
    os_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1d_os_version
GROUP BY (os_version,timestamp)
ORDER BY (timestamp,os_version)



