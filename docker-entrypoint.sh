#!/bin/bash


INSTANCE_HOSTNAME=$(curl -s http://rancher-metadata/latest/self/host/name)

if [[ -z $HOST_NAME ]]
then
  echo "Failed to get host's hostname from rancher-metadata API." > debug
fi


echo ${urlname}>/etc/hostname

curl http://rancher-metadata/latest/self/host/name > ~/hosts.new
cat ~/hosts.new > /etc/hostname
