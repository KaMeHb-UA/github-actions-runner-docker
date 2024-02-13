#!/bin/bash

if [ "$EUID" = '0' ]; then
    if [ -e /var/run/docker.sock ]; then
        chmod 666 /var/run/docker.sock
    fi
    chown -R docker /data
    exec su docker -c "$0"
    exit 0
fi

container_number=`docker ps --filter "id=$HOSTNAME" --format '{{.Label "com.docker.compose.container-number"}}'`

if [ "0${container_number}" = '0' ]; then
    container_number='1'
fi

mkdir -p /data/${container_number}/data
mkdir -p /data/${container_number}/.work
mkdir -p /home/docker/workdir

fuse-overlayfs -o lowerdir=/home/docker/actions-runner,upperdir=/data/${container_number}/data,workdir=/data/${container_number}/.work /home/docker/workdir

cd /home/docker/workdir

if [ ! -f .credentials ]; then
    echo "First launch, need a TOKEN environment variable to be specified to continue configuration"
    ./config.sh --url ${URL} --token ${TOKEN} --disableupdate
fi

./run.sh & wait $!
