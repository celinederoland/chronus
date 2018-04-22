#!/usr/bin/env bash

COMPOSER="off"
TESTS="off"
MAVEN="off"

while getopts n:t:c:u:m option
do
 case "${option}"
 in
 n) NAME=${OPTARG};;
 t) TYPE=${OPTARG};;
 c) COMPOSER="on";;
 u) TESTS="on";;
 m) MAVEN="on";;
 esac
done

cd projects
mkdir $NAME
cd $NAME

touch docker-compose.yml
touch readme.md

echo "version: '2'

services:
  $NAME:
    extends:
      file: ../../docker-services.yml
      service: $TYPE" > docker-compose.yml

if [ $TYPE = "java-tomcat-server" ]; then
  COMPOSEOVERRIDE="  $NAME:
    volumes:
      - ../code/$NAME/target/$NAME.war:/usr/local/tomcat/webapps/ROOT.war"
elif [ $TYPE = "php-web-server" ]; then
  echo "    environment:
      PHP_IDE_CONFIG: serverName=$NAME" >> docker-compose.yml
  COMPOSEOVERRIDE="  $NAME:
    volumes:
      - ../code/$NAME:/var/www/html"
fi;

COMPOSE="  $NAME:
    extends:
      file: projects/$NAME/docker-compose.yml
      service: $NAME";


echo "    networks:
      - front
      - back" >> docker-compose.yml

if [ $COMPOSER = "on" ]; then
  echo "
  $NAME-composer:
    extends:
      file: ../../docker-services.yml
      service: php-composer" >> docker-compose.yml

  echo "#!/usr/bin/env bash

cd \${BASH_SOURCE%/*}/../..
docker-compose run $NAME-composer composer \$@" > composer
  chmod a+x composer

  COMPOSEOVERRIDE="$COMPOSEOVERRIDE
  $NAME-composer:
    volumes:
      - ../code/$NAME:/app"
  COMPOSE="$COMPOSE
  $NAME-composer:
    extends:
      file: projects/$NAME/docker-compose.yml
      service: $NAME-composer";
fi

if [ $TESTS = "on" ]; then
echo "
  $NAME-tests:
    extends:
      file: ../../docker-services.yml
      service: php-test-server" >> docker-compose.yml

  COMPOSEOVERRIDE="$COMPOSEOVERRIDE
  $NAME-tests:
    volumes:
      - ../code/$NAME:/var/www/html"
  COMPOSE="$COMPOSE
  $NAME-tests:
    extends:
      file: projects/$NAME/docker-compose.yml
      service: $NAME-tests";
fi

if [ $MAVEN = "on" ]; then
echo "
  $NAME-maven:
    extends:
      file: ../../docker-services.yml
      service: java-maven" >> docker-compose.yml
  COMPOSE="$COMPOSE
  $NAME-maven:
    extends:
      file: projects/$NAME/docker-compose.yml
      service: $NAME-maven";
fi

echo "successfully created projects/$NAME/docker-compose.yml"
echo "empty readme.md created, please complete it"

echo ""
echo ""

echo "add the following lines to docker-compose.yml :
$COMPOSE"

echo ""
echo ""

echo "add the following lines to docker-compose.override.yml :
$COMPOSEOVERRIDE"

echo ""
echo ""

echo "add the following rules to haproxy.cfg"

echo "frontend http-in

    acl is_$NAME hdr_beg(host) $NAME

    use_backend $NAME if is_$NAME

    default_backend $NAME

backend $NAME
    server $NAME $NAME:80"

echo ""
echo ""

echo "add dependence from haproxy to $NAME in docker-compose.yml (services->haproxy->depends_on"

echo ""
echo ""

echo "add the following line to /etc/hosts"

echo "127.0.0.1    $NAME.localhost $NAME"
