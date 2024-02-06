#!/bin/bash

mkdir -p /data/data
mkdir -p /data/.work
mkdir -p /home/docker/workdir

fuse-overlayfs -o lowerdir=/home/docker/actions-runner,upperdir=/data/data,workdir=/data/.work /home/docker/workdir

sleep 1 # a hack to wait for workdir become alive

cd /home/docker/workdir

if [ ! -f .credentials ]; then
    echo "First launch, need a TOKEN environment variable to be specified to continue configuration"
    ./config.sh --url ${URL} --token ${TOKEN}
fi

./run.sh & wait $!
