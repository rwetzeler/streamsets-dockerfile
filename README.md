# StreamSets Data Collector

The Docker image for Data Collector starting from version 2.4.1.0 uses file based authentication by default. So you need to use user account to login. The default login is: admin / admin.

This docker image starts from version 2.6.0.0. It has custom config for SDC_DATA directory, installation for stagelibaries, setup email alerts.

Basic Usage
-----------
`docker run --restart on-failure -p 18630:18630 -d --name streamsets-dc streamsets/datacollector`

Detailed Usage
--------------
*   You can specify a custom configs by mounting them as a volume to /etc/sdc or /etc/sdc/<specific config>
*   Configuration properties in `sdc.properties` can also be overridden at runtime by specifying them env vars prefixed
    with SDC_CONF
*   You can set ADD_LIBS variable to install necessary stagelibaries. 
	The ones used here be default: 
	streamsets-datacollector-jdbc-lib
	streamsets-datacollector-apache-kafka_1_0-lib
	streamsets-datacollector-azure-lib
	streamsets-datacollector-elasticsearch_5-lib
	streamsets-datacollector-jython_2_7-lib
	streamsets-datacollector-redis-lib
*   Email alerts can be set by adding the configuration to EMAIL_HOST
*   External JAR file for Microsoft SQL server installed along with this image. 
*   Set SDC_DATA to create separate data containers. 
*	Support for custom config copy via `COPY_CONFIG` Env Variable - if you specify a value, it will copy to the `SDC_CONF` path.


Fork from [pavithrakc/streamsets-dockerfile
](https://hub.docker.com/r/pavithrakc/streamsets-dockerfile)