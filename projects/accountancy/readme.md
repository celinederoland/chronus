# run

- compile

docker-compose up accountancy-maven

- publish tests api

docker-compose up -d accountancy-test-api

- test

docker-compose up accountancy-maven-test

- create the prod database

- publish

docker-compose up -d accountancy  haproxy

- build and install the client application

  - set the packaging to .jar on pom.xml
  - docker-compose up accountancy-maven
  - distribute the Accountancy.jar and run.sh files to client
  - execute the run.sh file on client computer

# intelliJ run tests configuration

Environment variables : ACCOUNTANCY_DATABASE=localhost:3001/accountancy?user=root&password=secret&useSSL=false;ACCOUNTANCY_URL=http://localhost:8002;ACCOUNTANCY_TOKEN=secret

# intelliJ run configuration

Environment variables : ACCOUNTANCY_URL=http://accountancy.localhost;ACCOUNTANCY_TOKEN=secret