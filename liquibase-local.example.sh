#!/usr/bin/env bash

# /mnt/c/Users/<USER>/sb-projects

set -ex

DB_ADDRESS=<see service name in docker-compose.yml>
DB_PASSWORD=qwerty
DB_username=assistant_user

# psql -h ${DB_ADDRESS} -U ${DB_username} -d assistant_db -tc "CREATE SCHEMA IF NOT EXISTS assistant AUTHORIZATION assistant_user;"
docker run --rm -v ./resources/liquibase:/liquibase/changelog \
  mnpma/liquibase-pg:5.0 \
 --url=jdbc:postgresql://ti-assistant-db:5432/assistant_db \
  --username=${DB_USERNAME} \
  --password=${DB_PASSWORD} \
  --changeLogFile=liquibase-changelog.xml \
  --contexts=dev \
  update

# or one more possible case to run:
CONTAINER_NAME=
NETWORK=knowledge-network
 docker run --rm \
 --network ${NETWORK} \
 -v ./resources/liquibase:/liquibase/changelog \
 liquibase-pg:latest \
 --url=jdbc:postgresql://${CONTAINER_NAME}:5434/assistant_db \
  --username=${DB_username} \
  --password=${DB_PASSWORD} \
 --changeLogFile=liquibase-changelog.xml \
 --contexts=dev \
 update