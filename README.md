# ti-assistant-db

PostgreSQL database schema and Liquibase migrations for the TI Assistant application. The database stores assistant conversations, user questions, generated SQL results, document-search results, feedback, and execution metadata.

## Stack

- **Database:** PostgreSQL 17
- **Migration tool:** Liquibase 5.0.0
- **Containerization:** Docker and Docker Compose
- **Database driver:** PostgreSQL JDBC driver
- **Schema:** `assistant`
- **Database:** `assistant_db`

## Repository structure

```text
.
├── docker/
│   ├── assistant-init-scripts/
│   │   └── init.sql                         PostgreSQL initialization script
│   ├── liquibase-dockerfile-to-image/
│   │   ├── Dockerfile                       Liquibase image with PostgreSQL support
│   │   └── README.md                        Liquibase image instructions
│   └── docker-compose.yml                   Local PostgreSQL service
├── resources/
│   └── liquibase/
│       ├── liquibase-changelog.xml          Main Liquibase changelog
│       ├── liquibase.properties             Default Liquibase configuration
│       ├── liquibase-dev.examples.properties Example development configuration
│       ├── _01-schema/
│       │   ├── schema.xml                   Schema changelog
│       │   ├── _001_create_schema.sql       Creates the assistant schema
│       │   ├── _002_create_chat_table.sql   Creates the chat table
│       │   ├── _003_create_question_table.sql
│       │   ├── _004_create_document_result_table.sql
│       │   ├── _005_create_nlp2sql_result_table.sql
│       │   ├── _006_create_chat_index.sql
│       │   ├── _007_create_question_index.sql
│       │   └── _008_create_agents_index.sql
│       ├── _02-reference-data/
│       │   └── reference-data.xml            Reference-data changelog
│       ├── _03-data-type/
│       │   └── data-type.xml                 Data-type changelog
│       ├── _04-view/
│       │   └── view.xml                      View changelog
│       └── _05-function/
│           └── function.xml                  Function changelog
├── liquibase-local.example.sh               Local migration example
└── LIQUIBASE.md                              Detailed Liquibase notes
```

## Run `assistant_db` with Docker Compose and apply Liquibase migrations

This project runs PostgreSQL in Docker Compose and applies the database schema using Liquibase in a temporary Docker container.

### 1. Start PostgreSQL

From the repository root, start the database service:

```bash
cd docker
docker compose up -d
```

The Compose configuration starts the following PostgreSQL instance:

| Setting        | Value               |
|----------------|---------------------|
| Container name | `ti-assistant-db`   |
| Database       | `assistant_db`      |
| Username       | `assistant_user`    |
| Password       | `qwerty`            |
| Docker network | `knowledge-network` |
| Host port      | `5434`              |
| Container port | `5432`              |

Verify that the container is running:

```bash
docker ps
```

Check the PostgreSQL logs if necessary:

```bash
docker logs -f ti-assistant-db
```

> The `assistant` schema is created automatically by `docker/assistant-init-scripts/init.sql` when PostgreSQL initializes a new data volume.

### 2. Build the Liquibase image

Build the custom Liquibase image with the PostgreSQL driver:

```bash
docker build \
  -t liquibase-pg:latest \
  ./docker/liquibase-dockerfile-to-image
```

The image is based on Liquibase `5.0.0` and includes the PostgreSQL extension.

### 3. Apply Liquibase scripts to `assistant_db`

Run Liquibase from the repository root:

```bash
docker run --rm \
  --network knowledge-network \
  -v "$(pwd)/resources/liquibase:/liquibase/changelog" \
  liquibase-pg:latest \
  --url="jdbc:postgresql://ti-assistant-db:5432/assistant_db" \
  --username="assistant_user" \
  --password="qwerty" \
  --changeLogFile="liquibase-changelog.xml" \
  --contexts="dev" \
  update
```

This command:

1. Starts a temporary container from `liquibase-pg:latest`.
2. Connects it to the `knowledge-network` Docker network.
3. Mounts the local `resources/liquibase` directory at `/liquibase/changelog`.
4. Connects to PostgreSQL using the `ti-assistant-db` service name.
5. Loads `liquibase-changelog.xml`.
6. Applies the changesets configured for the `dev` context.
7. Removes the temporary Liquibase container after completion.

The migration creates the `assistant` schema and the following tables:

```text
assistant.chat
assistant.question
assistant.document_result
assistant.nlp2sql_result
```

It also creates the configured indexes and updates planner statistics where applicable.

> When Liquibase runs inside a container on the same Docker network, use `ti-assistant-db:5432`. The host mapping `5434:5432` is used only for connections from the host machine. Do not use `ti-assistant-db:5434` for container-to-container communication.

### 4. Run the migration again

Liquibase stores migration history in the `DATABASECHANGELOG` and `DATABASECHANGELOGLOCK` tables. Running the command again is normally safe:

```bash
docker run --rm \
  --network knowledge-network \
  -v "$(pwd)/resources/liquibase:/liquibase/changelog" \
  liquibase-pg:latest \
  --url="jdbc:postgresql://ti-assistant-db:5432/assistant_db" \
  --username="assistant_user" \
  --password="qwerty" \
  --changeLogFile="liquibase-changelog.xml" \
  --contexts="dev" \
  update
```

Only changesets that have not already been applied will be executed.

### 5. Connect to PostgreSQL from the host

Applications and database clients running on the host can connect using:

```text
Host:     localhost
Port:     5434
Database: assistant_db
Username: assistant_user
Password: qwerty
```

Example JDBC URL:

```text
jdbc:postgresql://localhost:5434/assistant_db
```

### 6. Reset the local database

To stop the database without deleting its data:

```bash
cd docker
docker compose down
```

To remove the database and its persisted Docker volume:

```bash
cd docker
docker compose down -v
```

> The `-v` option permanently deletes the local database. After the volume is removed, starting Docker Compose again runs the PostgreSQL initialization scripts against a fresh database.