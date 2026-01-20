FROM metabase/metabase:v0.53.18

ADD target/clickhouse.metabase-driver.jar /plugins/
RUN chmod 744 /plugins/clickhouse.metabase-driver.jar
