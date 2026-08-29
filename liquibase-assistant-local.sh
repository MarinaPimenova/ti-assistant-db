#!/usr/bin/env bash

# /mnt/c/Users/MarinaPimenova/sb-projects

set -ex

##echo "contextEnv: ${contextEnv}"
##DB_ADDRESS=jdbc:postgresql://localhost:5434/assistant_db
# url=jdbc:postgresql://host.docker.internal:5434/assistant_db
# DB_ADDRESS=172.25.9.62
DB_PASSWORD=qwerty
DB_username=assistant_user

export PGPASSWORD="${DB_PASSWORD}"
# psql -h ${DB_ADDRESS} -U ${DB_username} -d assistant_db -tc "CREATE SCHEMA IF NOT EXISTS assistant AUTHORIZATION assistant_user;"
 docker run --rm \
 --network knowledge-network \
 -v ./resources/liquibase:/liquibase/changelog \
 liquibase-pg:latest \
 --url=jdbc:postgresql://ti-assistant-db:5432/assistant_db \
 --username=assistant_user \
 --password=qwerty \
 --changeLogFile=liquibase-changelog.xml \
 --contexts=dev \
 update