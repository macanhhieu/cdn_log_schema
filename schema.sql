--Create database--
CREATE DATABASE cdn_log
--Part 1: nginx access datas
--1.1 create TABLE
  CREATE TABLE cdn_log.nginx_access_without_geoip (
  `timestamp`                  DateTime,
  `client_ip`                  String,
  `method`                     String,
  `url`                        String,
  `uri`                        String,
  `status`                     UInt32,
  `bytes`                      UInt32,
  `referer`                    String,
  `user_agent`                 String,
  `http_x_forwarded_for`       String,
  `hitmiss`                    String,
  `request_time`               Float32,
  `hostname`                   String,
  `status_ups`                 String,
  `request_time_ups`           Nullable(String),

  `browser_family`             Nullable(String),
  `browser_version`            Nullable(String),
  `browser_major`              Nullable(String),
  `browser_minor`              Nullable(String),

  `os_family`                  Nullable(String),
  `os_version`                 Nullable(String),
  `os_major`                   Nullable(String),
  `os_minor`                   Nullable(String),

  `device_family`              Nullable(String),
  `device_brand`               Nullable(String),
  `device_model`               Nullable(String),

  `channel`                    String,
  `name`                       String
) ENGINE = MergeTree() PARTITION BY toYYYYMM(timestamp)
ORDER BY
  (timestamp, client_ip) SETTINGS index_granularity = 8192
 
CREATE MATERIALIZED VIEW nginx_access
    ENGINE = MergeTree()
    PARTITION BY toYYYYMM(timestamp)
    ORDER BY (timestamp,client_ip)
    AS SELECT
        timestamp,
        client_ip,
        method,
        url,
        uri,
        status,
        bytes,
        referer,
        user_agent,
        http_x_forwarded_for,
        hitmiss,
        request_time,
        hostname,
        status_ups,
        ifNull(request_time_ups,toString('-'))                                                   AS request_time_ups,

        ifNull(browser_family,toString(''))                                                      AS browser_family,
        ifNull(browser_version,toString(''))                                                     AS browser_version,
        ifNull(browser_major,toString(''))                                                       AS browser_major,
        ifNull(browser_minor,toString(''))                                                       AS browser_minor,

        ifNull(os_family,toString(''))                                                           AS os_family,
        ifNull(os_version,toString(''))                                                          AS os_version,
        ifNull(os_major,toString(''))                                                            AS os_major,
        ifNull(os_minor,toString(''))                                                            AS os_minor,

        ifNull(device_family,toString('')) device_family,
        ifNull(device_brand,toString('')) device_brand,
        ifNull(device_model,toString('')) device_model,

        channel ,
        name ,

        dictGetUInt32('geoip_city_blocks_ipv4', 'geoname_id', tuple(IPv4StringToNum(client_ip))) AS geoname_id,
        dictGetString('geoip_city_locations_en', 'country_name', toUInt64(geoname_id))           AS country, 
        dictGetString('geoip_city_locations_en', 'subdivision_1_name', toUInt64(geoname_id))     AS city
    FROM 
    cdn_log.nginx_access_without_geoip  

--Part 2: varnish cache datas
--2.1 create TABLE
CREATE TABLE varnish_cache_without_geoip (
  `host`                          String,
  `client_ip`                     String,
  `timestamp`                     String,
  `request_line`                  String,
  `uri`                           String,
  `param`                         String,
  `response`                      Int64,
  `bytes_sent_client`             Int64,
  `referer`                       String,
  `user_agent`                    String,
  `request_time_tmp`              Int64,
  `bytes`                         Int64,
  `hitmiss`                       String,
  `varnish_time_firstbyte`        Float64,
  `varnish_handling`              String,
  `http_x_forwarded_for`          String,
  
  `browser_family`                Nullable(String),
  `browser_version`               Nullable(String),
  `browser_major`                 Nullable(String),
  `browser_minor`                 Nullable(String),

  `os_family`                     Nullable(String),
  `os_version`                    Nullable(String),
  `os_major`                      Nullable(String),
  `os_minor`                      Nullable(String),

  `device_family`                 Nullable(String),
  `device_brand`                  Nullable(String),
  `device_model`                  Nullable(String),
  
  channel                         String,
  name                            String
) ENGINE = MergeTree() 
    PARTITION BY toYYYYMM(time_write_log)
    ORDER BY (time_write_log,client_ip)
    
 --2.2 create TABLE that have been enriched geometry IP

CREATE MATERIALIZED VIEW vanish_cache
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (timestamp,client_ip)
AS SELECT
    host,
    client_ip,
    time_write_log                                                                          AS timestamp,
    request_line,
    uri,
    param,
    response,
    bytes_sent_client,
    referer,
    user_agent,
    request_time_tmp,
    bytes,
    hitmiss,
    varnish_time_firstbyte,
    varnish_handling,
    http_x_forwarded_for,
    
    ifNull(browser_family,toString(''))                                                      AS browser_family,
    ifNull(browser_version,toString(''))                                                     AS browser_version,
    ifNull(browser_major,toString(''))                                                       AS browser_major,
    ifNull(browser_minor,toString(''))                                                       AS browser_minor,

    ifNull(os_family,toString(''))                                                           AS os_family,
    ifNull(os_version,toString(''))                                                          AS os_version,
    ifNull(os_major,toString(''))                                                            AS os_major,
    ifNull(os_minor,toString(''))                                                            AS os_minor,

    ifNull(device_family,toString(''))                                                       AS device_family,
    ifNull(device_brand,toString(''))                                                        AS device_brand,
    ifNull(device_model,toString(''))                                                        AS device_model,
    
    channel ,
    name ,
    
    dictGetUInt32('geoip_city_blocks_ipv4', 'geoname_id', tuple(IPv4StringToNum(client_ip))) AS geoname_id,
    dictGetString('geoip_city_locations_en', 'country_name', toUInt64(geoname_id))           AS country, 
    dictGetString('geoip_city_locations_en', 'subdivision_1_name', toUInt64(geoname_id))     AS city
FROM 
cdn_log.varnish_cache_without_geoip


