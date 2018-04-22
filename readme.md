# PhpStorm config

## Docker base

- Settings -- Build, Execution, Deployment -- Docker

  - click `+`, define a name, choose Unix Socket option
  
- Settings -- Build, Execution, Deployment -- Docker -- Tools

  - Docker Compose executable : /base/path/workbox/docker/docker-compose.yml

- **Verify** View -- Tool Windows -- Docker. You must see docker containers

## Composer

- Settings -- Languages & Frameworks -- PHP -- Composer
  - Path to composer.json : /base/path/workbox/code/genesis/composer.json
  - Composer executable : /base/path/workbox/docker/projects/genesis/composer
  
- **Verify** Open composer.json and click update

## XDebug

- Settings -- Languages & Frameworks -- PHP -- Servers
  - click `+`, define a name, 
  - Host : <name>.localhost -- Port : 80 -- Debugger : XDebug
  - check Use path mappings, in 'project files' section, for the project root set the mapping to `/var/www/html`

- Settings -- Languages & Frameworks -- PHP -- Debug
  - In the XDebug section, set port to 5902
  
- **Verify** Add breakpoints and navigate to a page

## Unit Tests

- Settings -- Languages & Frameworks -- PHP

  - Cli interpreter: click `...`
  - click `+` -- From Docker, Vagrant etc
  - choose Docker Compose
    * Server : the name you have set on first step
    * Configuration files : /base/path/workbox/docker/docker-compose.yml;/base/path/workbox/docker/docker-compose.override.yml
    * Service : choose the tests container in the list

- Settings -- Languages & Frameworks -- PHP -- Test Frameworks

  - click `+` -- PHPUnit by Remote Interpreter
  - select the interpreter defined on previous step
 
- **Verify** right click on phpunit.xml -- Run phpunit.xml 
 
# HowTo create

## A basic php apache server

- /etc/hosts

127.0.0.1  basic.localhost basic

- haproxy.cfg

```
frontend http-in
    bind *:80

    acl is_basicphp hdr_beg(host) basicphp
    use_backend basicphp if is_basicphp

    default_backend basicphp

backend basicphp
    server basicphp basicphp:80
```

- projects/basicphp/docker-compose.yml

```
services:
  basicphp:
    extends:
      file: ../../docker-services.yml
      service: php-web-server
    volumes:
      - ./virtualhost.conf:/etc/apache2/sites-available/000-default.conf
    networks:
      - front
      - back
```

- docker-compose.yml

```
services:
  basicphp:
    extends:
      file: projects/basicphp/docker-compose.yml
      service: basicphp

```

- docker-compose.override.yml

```
services:
  basicphp:
    volumes:
      - ../code/basicphp:/var/www/html
```

## A MySql database

- resources/mydatabase/docker-compose.yml

```
services:
  mydatabase:
    extends:
      file: ../../docker-services.yml
      service: mysql-database
    networks:
      - back
#      - test
volumes:
  - mydatabase:/data

volumes:
  mydatabase:
    driver: local
```

- docker-compose.yml

```
services:
  mydatabase:
    extends:
      file: resources/mydatabase/docker-compose.yml
      service: mydatabase
```

- docker-compose.override.yml

```
services:
  mydatabase:
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: database
    ports:
      - N:3306
```

## A Java tomcat server managed with maven

- haproxy.cfg

```
frontend http-in
    bind *:80

    acl is_basicjava hdr_beg(host) basicjava
    use_backend basicjava if is_basicjava

    default_backend basicjava

backend basicjava
    server basicjava basicjava:8080
```

- projects/basicjava/docker-compose.yml

```
services:
  basicjava:
    extends:
      file: ../../docker-services.yml
      service: java-tomcat-server
    networks:
      - front
      - back

  basicjava-maven:
    extends:
      file: ../../docker-services.yml
      service: java-maven
    networks:
      - test
```

- docker-compose.yml

```
services:
  basicjava:
    extends:
      file: projects/basicjava/docker-compose.yml
      service: basicjava
  basicjava-maven:
    extends:
      file: projects/basicjava/docker-compose.yml
      service: basicjava-maven
```

- docker-compose.override.yml

```
services:
  basicjava:
    volumes:
      - ../code/accountancy/target/Basicjava.war:/usr/local/tomcat/webapps/ROOT.war
  basicjava-maven:
    volumes:
      - ../code/basicjava:/usr/src
```

- pom.xml

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <groupId>...</groupId>
    <artifactId>basicjava</artifactId>
    <packaging>war</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>Basicjava</name>

    <dependencies>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>4.0.0</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>Basicjava</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.7.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>
```

# Projects

- 