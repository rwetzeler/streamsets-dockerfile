#!/bin/bash

set -x
password=abc@123XYZ
mkdir -p ${SDC_DIST}/JNDI-Directory
echo ${FILEBEAT_LOG_DIR}
logdir=$(echo ${FILEBEAT_LOG_DIR} | sed 's/\\/\//g')
echo "mounting cifs drives from ${logdir} to /mnt/winshare"
mount.cifs -v \
         "//10.40.13.156/JNDI-Directory" -o username=Pavithra.KC,password=$password \
         "${SDC_DIST}/JNDI-Directory"  \
	  && echo "mount successfully"

