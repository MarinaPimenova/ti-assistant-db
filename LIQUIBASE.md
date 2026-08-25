# Liquibase Database Migration

This project uses **Liquibase** to manage and apply database schema changes 
to the PostgreSQL `assistant_db` database.

Liquibase is executed inside a temporary Docker container, 
so Liquibase does not need to be installed directly on the host machine.

## Command

```bash
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
```

## How It Works

The command performs the following steps:

1. Starts a temporary Docker container using the `liquibase-pg:latest` image.
2. Connects the container to the specified Docker network.
3. Mounts the local Liquibase changelog directory into the container.
4. Connects Liquibase to the PostgreSQL `assistant_db` database.
5. Uses the specified database credentials.
6. Loads `liquibase-changelog.xml`.
7. Applies changesets configured for the `dev` context.
8. Removes the Liquibase container after execution.

```text
Host
│
├── resources/
│   └── liquibase/
│       ├── liquibase-changelog.xml
│       └── ...
│
│       │
│       │ Docker bind mount
│       ▼
│
└── Liquibase container
    │
    ├── /liquibase/changelog/
    │   └── liquibase-changelog.xml
    │
    └── Liquibase
            │
            │ JDBC
            ▼
       PostgreSQL container
       │
       └── assistant_db
```

---

## Docker Options

### `docker run`

Creates and starts a new container from the specified Docker image.

```bash
docker run
```

The container is used only for executing the Liquibase migration.

### `--rm`

```bash
--rm
```

Automatically removes the container when Liquibase finishes.

This keeps the Docker environment clean and prevents stopped Liquibase containers from accumulating.

Without `--rm`, every execution could leave an exited container behind.

### `--network ${NETWORK}`

```bash
--network ${NETWORK}
```

Connects the Liquibase container to the Docker network specified by the `NETWORK` environment variable.

For example:

```bash
export NETWORK=training-network
```

The container then becomes a member of:

```text
training-network
```

This is important because `${CONTAINER_NAME}` is expected to resolve to a PostgreSQL container/service reachable through this Docker network.

For example:

```text
Docker network: training-network

┌──────────────────────────────┐
│ training-network             │
│                              │
│  ┌────────────────────────┐  │
│  │ Liquibase container    │  │
│  └───────────┬────────────┘  │
│              │ JDBC          │
│              ▼               │
│  ┌────────────────────────┐  │
│  │ PostgreSQL container   │  │
│  │ assistant_db           │  │
│  └────────────────────────┘  │
│                              │
└──────────────────────────────┘
```

> **Note:** This is different from `--network=host`. Here Liquibase joins a specific Docker network rather than using the host's network namespace.

### `-v ./resources/liquibase:/liquibase/changelog`

```bash
-v ./resources/liquibase:/liquibase/changelog
```

Creates a Docker bind mount.

The syntax is:

```text
-v <host-path>:<container-path>
```

Therefore:

```text
./resources/liquibase
        │
        │ mounted into
        ▼
/liquibase/changelog
```

For example, if the project contains:

```text
project/
├── resources/
│   └── liquibase/
│       ├── liquibase-changelog.xml
│       ├── changes/
│       │   ├── 001-create-tables.xml
│       │   └── 002-create-indexes.xml
│       └── ...
└── ...
```

then the same files are available inside the container:

```text
/liquibase/changelog/
├── liquibase-changelog.xml
├── changes/
│   ├── 001-create-tables.xml
│   └── 002-create-indexes.xml
└── ...
```

The files are **not copied into the Docker image**. They are made available to the container through the bind mount.

---

## Docker Image

```bash
liquibase-pg:latest
```

This is the Docker image used to execute Liquibase.

The image presumably contains:

* Liquibase
* PostgreSQL JDBC driver
* Required Liquibase configuration/dependencies

The `latest` tag means Docker will use the image tagged `latest`.

For reproducible CI/CD builds, it is generally preferable to use a fixed image version, for example:

```bash
liquibase-pg:4.12
```

or preferably an immutable image digest.

---

# Liquibase Configuration

Everything after:

```bash
liquibase-pg:latest
```

is passed to Liquibase.

The general structure is:

```bash
docker run [Docker options] [image] [Liquibase options] [command]
```

---

## Database URL

```bash
--url=jdbc:postgresql://${CONTAINER_NAME}:5434/assistant_db
```

Defines the PostgreSQL JDBC connection URL.

The URL has the following structure:

```text
jdbc:postgresql://<host>:<port>/<database>
```

In this case:

```text
Host:     ${CONTAINER_NAME}
Port:     5434
Database: assistant_db
```

For example, if:

```bash
CONTAINER_NAME=postgres
```

the resulting URL is:

```text
jdbc:postgresql://postgres:5434/assistant_db
```

Because the Liquibase container and PostgreSQL container are connected to the same Docker network, Docker DNS can resolve the PostgreSQL container name.

```text
Liquibase
    │
    │ jdbc:postgresql://postgres:5434/assistant_db
    │
    ▼
postgres:5434
    │
    ▼
assistant_db
```

### Why not use `localhost`?

Inside a Docker container:

```text
localhost
```

refers to **the Liquibase container itself**, not the PostgreSQL container.

Therefore, this would normally be incorrect:

```bash
jdbc:postgresql://localhost:5434/assistant_db
```

Instead, the PostgreSQL container/service name should be used:

```bash
jdbc:postgresql://${CONTAINER_NAME}:5434/assistant_db
```

---

## Database Username

```bash
--username=${DB_username}
```

Specifies the PostgreSQL username.

The value is taken from the `DB_username` environment variable.

For example:

```bash
export DB_username=assistant_admin
```

results in:

```bash
--username=assistant_admin
```

For consistency, environment variable names are usually written in uppercase:

```bash
DB_USERNAME
```

So a more conventional version would be:

```bash
--username=${DB_USERNAME}
```

---

## Database Password

```bash
--password=${DB_PASSWORD}
```

Specifies the PostgreSQL password.

The value is taken from:

```bash
DB_PASSWORD
```

For example:

```bash
export DB_PASSWORD=********
```

### Security consideration

Avoid putting the password directly into the README or source code:

```bash
--password=mySecretPassword
```

Use an environment variable or another secret-management mechanism instead.

Also be aware that command-line arguments can potentially be visible to process inspection or CI/CD logging, depending on the environment.

---

# Changelog File

```bash
--changeLogFile=liquibase-changelog.xml
```

Specifies the main Liquibase changelog file.

Because the host directory:

```text
./resources/liquibase
```

is mounted to:

```text
/liquibase/changelog
```

Liquibase can access:

```text
/liquibase/changelog/liquibase-changelog.xml
```

The main changelog may then reference additional changelog files.

For example:

```xml
<include file="changes/001-create-tables.xml"/>
<include file="changes/002-create-indexes.xml"/>
```

---

# Liquibase Context

```bash
--contexts=dev
```

Specifies that Liquibase should execute changesets associated with the `dev` context.

For example:

```xml
<changeSet
    id="001"
    author="developer"
    context="dev">

    ...
    
</changeSet>
```

This allows changesets to be selectively executed for different environments.

Typical contexts might be:

```text
dev
test
uat
prod
```

For example:

```bash
--contexts=dev
```

can be used for the development database, while a deployment pipeline could use:

```bash
--contexts=prod
```

for production-specific changesets.

---

# `update`

```bash
update
```

This is the Liquibase command that performs the migration.

Liquibase compares the changelog with the changes already executed in the database.

Liquibase maintains its migration history in tables such as:

```text
DATABASECHANGELOG
DATABASECHANGELOGLOCK
```

For example:

```text
liquibase-changelog.xml

001-create-user-table
002-create-task-table
003-create-index
004-add-status-column
```

If the database already contains:

```text
001
002
003
```

then:

```bash
update
```

will apply:

```text
004-add-status-column
```

and record the execution in `DATABASECHANGELOG`.

Therefore, running the command repeatedly is normally safe:

```text
First execution
    │
    ├── 001 → execute
    ├── 002 → execute
    └── 003 → execute
             │
             ▼
       DATABASECHANGELOG


Second execution
    │
    ├── 001 → already executed
    ├── 002 → already executed
    └── 003 → already executed
             │
             ▼
        Nothing to update
```

---

# Environment Variables

The command expects the following environment variables:

| Variable         | Description                                        | Example            |
| ---------------- | -------------------------------------------------- | ------------------ |
| `NETWORK`        | Docker network containing Liquibase and PostgreSQL | `training-network` |
| `CONTAINER_NAME` | PostgreSQL container/service name                  | `postgres`         |
| `DB_username`    | PostgreSQL username                                | `assistant_admin`  |
| `DB_PASSWORD`    | PostgreSQL password                                | `********`         |

Example:

```bash
export NETWORK=training-network
export CONTAINER_NAME=postgres
export DB_USERNAME=assistant_admin
export DB_PASSWORD=********
```

> If you rename `DB_username` to `DB_USERNAME`, remember to update the Docker command accordingly.

---

# Prerequisites

Before running the migration, make sure:

1. Docker is installed and running.
2. The PostgreSQL container is running.
3. PostgreSQL and Liquibase are connected to the same Docker network.
4. The `assistant_db` database exists.
5. The database credentials are valid.
6. `resources/liquibase/liquibase-changelog.xml` exists.
7. The `liquibase-pg:latest` Docker image is available locally.

You can verify the Docker network with:

```bash
docker network ls
```

And inspect it with:

```bash
docker network inspect ${NETWORK}
```

---

# Example

Assume:

```bash
NETWORK=training-network
CONTAINER_NAME=postgres
DB_USERNAME=assistant_admin
DB_PASSWORD=secret
```

The command effectively becomes:

```bash
docker run --rm \
  --network training-network \
  -v ./resources/liquibase:/liquibase/changelog \
  liquibase-pg:latest \
  --url=jdbc:postgresql://postgres:5434/assistant_db \
  --username=assistant_admin \
  --password=secret \
  --changeLogFile=liquibase-changelog.xml \
  --contexts=dev \
  update
```

The resulting architecture is:

```text
                    Docker host
                         │
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼
      ┌───────────────┐       ┌───────────────┐
      │ Liquibase     │       │ PostgreSQL    │
      │ container     │       │ container     │
      │               │       │               │
      │ liquibase-pg  │       │ assistant_db  │
      │               │       │               │
      │ /liquibase/   │       │ :5434         │
      │ changelog/    │       │               │
      └───────┬───────┘       └───────▲───────┘
              │                        │
              │ JDBC                   │
              └────────────────────────┘
                    Docker network
                    ${NETWORK}

Host:
./resources/liquibase
          │
          │ bind mount
          ▼
/liquibase/changelog
```

---

# Recommended Script

For local development, the command can be wrapped in a script:

```bash
#!/bin/bash

docker run --rm \
  --network "${NETWORK}" \
  -v "$(pwd)/resources/liquibase:/liquibase/changelog" \
  liquibase-pg:latest \
  --url="jdbc:postgresql://${CONTAINER_NAME}:5434/assistant_db" \
  --username="${DB_USERNAME}" \
  --password="${DB_PASSWORD}" \
  --changeLogFile=liquibase-changelog.xml \
  --contexts=dev \
  update
```

This makes the migration easier to execute and avoids having to remember the complete Docker command.
