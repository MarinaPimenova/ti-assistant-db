#!/usr/bin/env bash

set -ex

DB_ADDRESS="${DB_ADDRESS:-ti-assistant-db:5432}"
DB_PASSWORD=qwerty
DB_USERNAME=assistant_user

# psql -h ${DB_ADDRESS} -U ${DB_username} -d assistant_db -tc "CREATE SCHEMA IF NOT EXISTS assistant AUTHORIZATION assistant_user;"
 docker run --rm \
 --network knowledge-network \
 -v ./resources/liquibase:/liquibase/changelog \
  mnpma/liquibase-pg:5.0 \
 --url=jdbc:postgresql://ti-assistant-db:5432/assistant_db \
  --username=${DB_USERNAME} \
  --password=${DB_PASSWORD} \
 --changeLogFile=liquibase-changelog.xml \
 --contexts=dev \
 update