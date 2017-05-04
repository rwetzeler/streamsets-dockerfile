FROM alpine:3.4

MAINTAINER Pavithra K C <Pavithra.KC@intlfcstone.com>

ARG SDC_USER=sdc

RUN apk --no-cache add bash \
    curl \
    krb5-libs \
    libstdc++ \
    sed
	
ENV SDC_CONF=/etc/sdc \
    SDC_DATA=/usr/share/streamsets/data \
    SDC_DIST="/opt/streamsets-datacollector" \
    SDC_LOG=/logs \
    SDC_RESOURCES=/resources
ENV STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/streamsets-libs-extras"

RUN addgroup -S ${SDC_USER} && \
    adduser -S ${SDC_USER} ${SDC_USER}
	
# Create necessary directories.
RUN mkdir -p /mnt \
    "${SDC_DATA}" \
    "${SDC_LOG}" \
    "${SDC_RESOURCES}"

# Move configuration to /etc/sdc
RUN mv "${SDC_DIST}/etc" "${SDC_CONF}"

# Use short option -s as long option --status is not supported on alpine linux.
RUN sed -i 's|--status|-s|' "${SDC_DIST}/libexec/_stagelibs"

# Setup filesystem permissions.
RUN chown -R "${SDC_USER}:${SDC_USER}" "${SDC_DIST}/streamsets-libs" \
    "${SDC_CONF}" \
    "${SDC_DATA}" \
    "${SDC_LOG}" \
    "${SDC_RESOURCES}" \
    "${STREAMSETS_LIBRARIES_EXTRA_DIR}"

USER ${SDC_USER}
EXPOSE 18630
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]	
