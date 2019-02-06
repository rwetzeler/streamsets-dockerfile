FROM streamsets/datacollector:3.5.0
MAINTAINER Rob Wetzeler <rob.wetzeler@gmail.com>
# FORKED FROM Pavithra K C <Pavithra.KC@intlfcstone.com>
# https://github.com/pavithrachandrakasu/streamsets-dockerfile

ARG SDC_USER=sdc

# Set stagelibs
ARG ADD_LIBS=streamsets-datacollector-jdbc-lib,streamsets-datacollector-apache-kafka_1_0-lib,streamsets-datacollector-azure-lib,streamsets-datacollector-elasticsearch_5-lib,streamsets-datacollector-jython_2_7-lib,streamsets-datacollector-redis-lib
ENV ADD_LIBS=$ADD_LIBS

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



RUN mkdir -p ${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib \
  && mkdir -p ${SDC_DATA} \
  && mkdir -p ${REMOTE_SHARE}

# Setup Mail alerts
RUN  sed -i  "/xmail.from.address=/c\xmail.from.address=streamsets_alert" /etc/sdc/sdc.properties \
  && sed -i -e 's/localhost/apps-outbound.emailserver.com/1' /etc/sdc/sdc.properties


# Set permissions on shared libs folder

RUN chown -R "${SDC_USER}:${SDC_USER}" "${STREAMSETS_LIBRARIES_EXTRA_DIR}" \
  "${SDC_CONF}" \
  "${SDC_DATA}" \
  "${SDC_LOG}" \
  "${REMOTE_SHARE}" \
  "${SDC_RESOURCES}" \
  "/etc/hostname" \
  "${SDC_DIST}"

# sharedconfig
RUN if [[ ! -z $COPY_CONFIG ]]; then cp ${COPY_CONFIG} /etc/sdc; fi

# Download and extract jdbc drivers

RUN cd /tmp && \
  curl -O -L "https://raw.github.com/rwetzeler/streamsets-dockerfile/master/jdbc_drivers/mssql-jdbc-7.0.0.jre10.jar" && \
  mv mssql-jdbc-7.0.0.jre10.jar "${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib"

RUN cd /tmp && \
  curl -O -L "https://raw.github.com/rwetzeler/streamsets-dockerfile/master/jdbc_drivers/dremio-jdbc-driver-3.1.1.jar" && \
  mv dremio-jdbc-driver-3.1.1.jar "${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib"

  RUN cd /tmp && \
  curl -O -L "https://raw.github.com/rwetzeler/streamsets-dockerfile/master/jdbc_drivers/postgres-42.2.5.jre7.jar" && \
  mv postgres-42.2.5.jre7.jar "${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib"

#setup for data to new volume storage

COPY docker-entrypoint.sh  /
RUN chmod o+x /docker-entrypoint.sh
EXPOSE 18630

USER ${SDC_USER}
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]