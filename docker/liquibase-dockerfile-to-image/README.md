## Create Liquibase image with Postgre driver
Run the following to create image based on Dockerfile:

docker build -t liquibase-pg .

## Find IP address
ip addr output, your primary host IP 
(the one your computer uses to talk to the network) 
is on the eth0 interface.

# run the docker command from the project/ directory.

## Prerequisites

Before executing Liquibase:

Start PostgreSQL:

```bash
cd docker
docker compose up -d
```

1. Verify PostgreSQL is available:

```bash
docker ps
```
2. Run Liquibase migration from project root

project/

├── resources/
│   └── liquibase/
│       └── liquibase-changelog.xml  <-- The file is here

The result should be:

Starting Liquibase at 20:39:28 using Java 21.0.8 (version 5.0.0 #9369 built at 2025-09-29 17:12+0000)
Liquibase Version: 5.0.0

Running Changeset: liquibase-changelog.xml::1::pm
...
