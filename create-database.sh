#!/usr/bin/env bash

VOLUME="off"

while getopts n:t:v option
do
 case "${option}"
 in
 n) NAME=${OPTARG};;
 t) TYPE=${OPTARG};;
 v) VOLUME="on";;
 esac
done


cd resources
mkdir $NAME
cd $NAME

touch docker-compose.yml
touch readme.md

echo "version: '2'

services:
  $NAME:
    extends:
      file: ../../docker-services.yml
      service: $TYPE-database" > docker-compose.yml

if [ $VOLUME = "on" ]; then
 echo "volumes:
  - $NAME-datas:/data

volumes:
  $NAME-datas:
    driver: local" >> docker-compose.yml
fi

echo "successfully created resources/$NAME/docker-compose.yml"
echo "empty readme.md created, please complete it"
echo "add the following lines to docker-compose.yml :
  $NAME-datas:
    extends:
      file: resources/$NAME/docker-compose.yml
      service: $NAME"
