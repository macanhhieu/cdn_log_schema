--1.6 Create MATERIALIZED VIEW 5m by browser_family

CREATE MATERIALIZED VIEW nginx_5m_browser_family
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,    
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)
LIMIT 100

  ----------+ The query users mv 
  SELECT
    browser_family,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM nginx_5m_browser_family
GROUP BY (browser_family,timestamp,request_totals)
ORDER BY (timestamp,browser_family)
LIMIT 100

--1.7 Create MATERIALIZED VIEW 30m by browser_family

CREATE MATERIALIZED VIEW nginx_30m_browser_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_family,timestamp)
AS SELECT
    browser_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_5m_browser_family
ORDER BY (timestamp,browser_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM nginx_access
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)

  ----------+ The query users mv 
SELECT
    browser_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_30m_browser_family
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)

--1.8 Create MATERIALIZED VIEW 1h by browser_family
CREATE MATERIALIZED VIEW nginx_1h_browser_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_family,timestamp)
AS SELECT
    browser_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_30m_browser_family
ORDER BY (timestamp,browser_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (browser_family,timestamp)
ORDER BY (browser_family,timestamp)

  ----------+ The query users mv 
  SELECT
    browser_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1h_browser_family
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)

--1.9 Create MATERIALIZED VIEW 1d by browser_family


CREATE MATERIALIZED VIEW nginx_1d_browser_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (browser_family,timestamp)
AS SELECT
    browser_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_1h_browser_family
ORDER BY (timestamp,browser_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (browser_family,timestamp)
ORDER BY (browser_family,timestamp)

  ----------+ The query users mv 
    SELECT
    browser_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1d_browser_family
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)


DROP TABLE nginx_5m_browser_version
--1.10 Create MATERIALIZED VIEW 5m by browser_version
CREATE MATERIALIZED VIEW nginx_5m_browser_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_version,timestamp)
AS SELECT
    DISTINCT browser_version                        AS browser_version, 
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_version,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,     
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM nginx_access
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

  ----------+ The query users mv 
  SELECT
    browser_version,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM nginx_5m_browser_version
GROUP BY (browser_version,timestamp,request_totals)
ORDER BY (timestamp,browser_version)

--1.11 Create MATERIALIZED VIEW 30m by browser_version
CREATE MATERIALIZED VIEW nginx_30m_browser_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_version,timestamp)
AS SELECT
    browser_version,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_5m_browser_version
ORDER BY (timestamp,browser_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_version,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    sum(bytes)                                       AS bytes_totals,
    count()                                          AS request_totals
FROM nginx_access
GROUP BY (browser_version,timestamp)
ORDER BY (browser_version,timestamp)

  ----------+ The query users mv 
SELECT
    browser_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_30m_os_version
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

--1.12 Create MATERIALIZED VIEW 1h by browser_version
CREATE MATERIALIZED VIEW nginx_1h_browser_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_version,timestamp)
AS SELECT
    browser_version,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_30m_browser_version
ORDER BY (timestamp,browser_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_version,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (browser_version,timestamp)
ORDER BY (browser_version,timestamp)

  ----------+ The query users mv 
SELECT
    browser_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1h_device_brand
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

--1.13 Create MATERIALIZED VIEW 1d by browser_version
CREATE MATERIALIZED VIEW nginx_1d_browser_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (browser_version,timestamp)
AS SELECT
    browser_version,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM nginx_1h_browser_version
ORDER BY (timestamp,browser_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_version,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM nginx_access
GROUP BY (browser_version,timestamp)
ORDER BY (browser_version,timestamp)

  ----------+ The query users mv 
SELECT
    browser_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM nginx_1d_os_version
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

-------------------------------------------------------------------------------
--PART 2: VARNISH CACHE
--1.6 Create MATERIALIZED VIEW 5m by browser_family

CREATE MATERIALIZED VIEW varnish_5m_browser_family
    ENGINE = AggregatingMergeTree()
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (timestamp)
AS SELECT
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,    
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)
LIMIT 100

  ----------+ The query users mv 
  SELECT
    browser_family,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM varnish_5m_browser_family
GROUP BY (browser_family,timestamp,request_totals)
ORDER BY (timestamp,browser_family)
LIMIT 100

--1.7 Create MATERIALIZED VIEW 30m by browser_family

CREATE MATERIALIZED VIEW varnish_30m_browser_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_family,timestamp)
AS SELECT
    browser_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM varnish_5m_browser_family
ORDER BY (timestamp,browser_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    sum(bytes) AS bytes_totals,
    count() AS request_totals
FROM varnish_cache
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)

  ----------+ The query users mv 
SELECT
    browser_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_30m_browser_family
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)

--1.8 Create MATERIALIZED VIEW 1h by browser_family
CREATE MATERIALIZED VIEW varnish_1h_browser_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_family,timestamp)
AS SELECT
    browser_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM varnish_30m_browser_family
ORDER BY (timestamp,browser_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (browser_family,timestamp)
ORDER BY (browser_family,timestamp)

  ----------+ The query users mv 
  SELECT
    browser_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1h_browser_family
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)

--1.9 Create MATERIALIZED VIEW 1d by browser_family


CREATE MATERIALIZED VIEW varnish_1d_browser_family
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (browser_family,timestamp)
AS SELECT
    browser_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM varnish_1h_browser_family
ORDER BY (timestamp,browser_family)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_family,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (browser_family,timestamp)
ORDER BY (browser_family,timestamp)

  ----------+ The query users mv 
    SELECT
    browser_family,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1d_browser_family
GROUP BY (browser_family,timestamp)
ORDER BY (timestamp,browser_family)



--1.10 Create MATERIALIZED VIEW 5m by browser_version
CREATE MATERIALIZED VIEW varnish_5m_browser_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_version,timestamp)
AS SELECT
    DISTINCT browser_version                        AS browser_version, 
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_version,
    toStartOfInterval(timestamp, INTERVAL 5 minute) AS timestamp,     
    sum(bytes)                                      AS bytes_totals,
    count()                                         AS request_totals
FROM varnish_cache
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

  ----------+ The query users mv 
  SELECT
    browser_version,
    timestamp,
    sum(bytes_totals) AS bytes_totals,
    request_totals
FROM varnish_5m_browser_version
GROUP BY (browser_version,timestamp,request_totals)
ORDER BY (timestamp,browser_version)

--1.11 Create MATERIALIZED VIEW 30m by browser_version
CREATE MATERIALIZED VIEW varnish_30m_browser_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_version,timestamp)
AS SELECT
    browser_version,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    bytes_totals,
    request_totals
FROM varnish_5m_browser_version
ORDER BY (timestamp,browser_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_version,
    toStartOfInterval(timestamp, INTERVAL 30 minute) AS timestamp,
    sum(bytes)                                       AS bytes_totals,
    count()                                          AS request_totals
FROM varnish_cache
GROUP BY (browser_version,timestamp)
ORDER BY (browser_version,timestamp)

  ----------+ The query users mv 
SELECT
    browser_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_30m_os_version
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

--1.12 Create MATERIALIZED VIEW 1h by browser_version
CREATE MATERIALIZED VIEW varnish_1h_browser_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMMDD(timestamp)
    ORDER BY (browser_version,timestamp)
AS SELECT
    browser_version,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    bytes_totals,
    request_totals
FROM varnish_30m_browser_version
ORDER BY (timestamp,browser_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_version,
    toStartOfInterval(timestamp, INTERVAL 1 hour) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (browser_version,timestamp)
ORDER BY (browser_version,timestamp)

  ----------+ The query users mv 
SELECT
    browser_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1h_device_brand
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)

--1.13 Create MATERIALIZED VIEW 1d by browser_version
CREATE MATERIALIZED VIEW varnish_1d_browser_version
    ENGINE = SummingMergeTree((bytes_totals,request_totals))
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (browser_version,timestamp)
AS SELECT
    browser_version,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    bytes_totals,
    request_totals
FROM varnish_1h_browser_version
ORDER BY (timestamp,browser_version)

----driver:
-----------+The query does not use mv
SELECT 
    DISTINCT browser_version,
    toStartOfInterval(timestamp, INTERVAL 1 day) AS timestamp,
    
    sum(bytes) AS bytes_totals,
    count()    AS request_totals
FROM varnish_cache
GROUP BY (browser_version,timestamp)
ORDER BY (browser_version,timestamp)

  ----------+ The query users mv 
SELECT
    browser_version,
    timestamp,
    sum(bytes_totals),
    sum(request_totals)
FROM varnish_1d_os_version
GROUP BY (browser_version,timestamp)
ORDER BY (timestamp,browser_version)



