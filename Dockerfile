FROM streamsets/datacollector:2.7.0.0
MAINTAINER Pavithra K C <Pavithra.KC@intlfcstone.com>

#ARG SDC_URL=https://archives.streamsets.com/datacollector/2.4.1.0/tarball/streamsets-datacollector-core-2.4.1.0.tgz
ARG SDC_USER=sdc


ENV ADD_LIBS=streamsets-datacollector-jdbc-lib,streamsets-datacollector-apache-kafka_0_9-lib,streamsets-datacollector-apache-kafka_0_10-lib,streamsets-datacollector-azure-lib,streamsets-datacollector-elasticsearch_5-lib,streamsets-datacollector-jython_2_7-lib
	 
USER root

RUN apk --no-cache add bash \
    curl \
    krb5-libs \
    libstdc++ \
    sed \
	cifs-utils



# Fix the stagelibs command to run on Alpine Linux 
RUN sed -i -e 's/run sha1sum --status/run sha1sum -s/g'  ${SDC_DIST}/libexec/_stagelibs

# Install the necessary stagelibraries 

RUN if [[ ! -z $ADD_LIBS ]]; then $SDC_DIST/bin/streamsets stagelibs -install=$ADD_LIBS ; fi



ENV SDC_DATA=/usr/share/streamsets/data
ENV REMOTE_SHARE=/mnt/remoteshare
#ENV SDC_VERSION ${SDC_VERSION:-2.4.1.0}
#ENV SDC_DIST="/opt/streamsets-datacollector-${SDC_VERSION}"
#ENV STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/libs-common-lib"

RUN mkdir -p ${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib

RUN mkdir -p ${SDC_DATA}

RUN mkdir -p ${REMOTE_SHARE}

# Setup Mail alerts 
RUN  sed -i -e 's/sdc@$localhost/streamsets_alert/' /etc/sdc/sdc.properties
RUN  sed -i -e 's/localhost/apps-outbound.fcstone.com/1' /etc/sdc/sdc.properties


# Set permissions on shared libs folder

RUN chown -R "${SDC_USER}:${SDC_USER}" "${STREAMSETS_LIBRARIES_EXTRA_DIR}" \
"${SDC_CONF}" \
    "${SDC_DATA}" \
    "${SDC_LOG}" \
	"${REMOTE_SHARE}" \
    "${SDC_RESOURCES}" \
	"/etc/hostname"
	
RUN chmod 777 "/etc/hostname"
	
# Download and extract jdbc driver
RUN cd /tmp && \
  curl -O -L "https://raw.github.com/pavithrachandrakasu/streamsets-dockerfile/master/sqljdbc42.jar" && \
  mv sqljdbc42.jar "${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib"


USER ${SDC_USER}
EXPOSE 18630
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]



