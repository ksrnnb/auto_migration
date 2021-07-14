#!/bin/bash

# run docker
function runDocker() {
  docker-compose up -d
  docker-compose run db bash migrate_main.sh "$@"
  docker-compose down
}

CONTAINER_ID=`docker ps | awk '{print $1}' | tail -1`

# dockerが起動していない場合
if [ "$CONTAINER_ID" = CONTAINER ]
then
  runDocker "$@"
else
  echo "Docker is already running"
fi