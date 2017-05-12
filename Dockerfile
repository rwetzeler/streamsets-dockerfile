FROM streamsets/datacollector:2.5.0.0
MAINTAINER Pavithra K C <Pavithra.KC@intlfcstone.com>

#ARG SDC_URL=https://archives.streamsets.com/datacollector/2.4.1.0/tarball/streamsets-datacollector-core-2.4.1.0.tgz
ARG SDC_USER=sdc


ENV ADD_LIBS=streamsets-datacollector-jdbc-lib,streamsets-datacollector-apache-kafka_0_9-lib
	 
USER root

RUN apk --no-cache add bash \
    curl \
    krb5-libs \
    libstdc++ \
    sed

# Fix the stagelibs command to run on Alpine Linux 
RUN sed -i -e 's/run sha1sum --status/run sha1sum -s/g'  ${SDC_DIST}/libexec/_stagelibs

# Install the necessary stagelibraries 

RUN if [[ ! -z $ADD_LIBS ]]; then $SDC_DIST/bin/streamsets stagelibs -install=$ADD_LIBS ; fi


ENV SDC_DATA=/usr/share/streamsets/data
#ENV SDC_VERSION ${SDC_VERSION:-2.4.1.0}
#ENV SDC_DIST="/opt/streamsets-datacollector-${SDC_VERSION}"
#ENV STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/libs-common-lib"

RUN mkdir -p ${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib

RUN mkdir -p ${SDC_DATA}
	
# Setup Mail alerts 
RUN  sed -i -e 's/localhost/apps-outbound.fcstone.com/' /etc/sdc/sdc.properties
RUN  sed -i -e 's/sdc@$localhost/streamsets_alert/' /etc/sdc/sdc.properties


# Set permissions on shared libs folder

RUN chown -R "${SDC_USER}:${SDC_USER}" "${STREAMSETS_LIBRARIES_EXTRA_DIR}" \
"${SDC_CONF}" \
    "${SDC_DATA}" \
    "${SDC_LOG}" \
    "${SDC_RESOURCES}" 
	
# Download and extract jdbc driver
RUN cd /tmp && \
  curl -O -L "https://raw.github.com/pavithrachandrakasu/streamsets-dockerfile/master/sqljdbc42.jar" && \
  mv sqljdbc42.jar "${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib"

USER ${SDC_USER}
EXPOSE 18630
#COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]



