# DB Schema

Generated from the Liquibase DDL in `resources/liquibase/_01-schema`.
`resources/liquibase/_02-reference-data/reference-data.xml` has no active changesets
(everything in it is commented out), so it contributes no tables or data.

```mermaid
erDiagram
    CHAT {
        bigint id PK
        uuid conversation_id "UNIQUE"
        text start_question
        varchar_100 chat_name
        varchar_100 user_id
        varchar_256 created_by "NOT NULL, default 'service-account'"
        timestamptz created_date "NOT NULL, default now()"
        varchar_256 modified_by
        timestamptz modified_date
    }

    QUESTION {
        bigint id PK
        bigint chat_id FK
        uuid conversation_id "NOT NULL"
        varchar_100 user_id
        text question "NOT NULL"
        varchar_1024 agent_name_list
        text llm_response
        jsonb source_list
        jsonb document_list
        varchar_50 user_feedback
        varchar_100 status "CHECK IN (created, in progress, failed, completed, canceled, timed out, integration error); default 'created'"
        text follow_up_question
        varchar_256 created_by "NOT NULL, default 'service-account'"
        timestamptz created_date "NOT NULL, default now()"
        varchar_256 modified_by
        timestamptz modified_date
    }

    DOCUMENT_RESULT {
        bigint id PK
        bigint question_id FK
        text sql_text "NOT NULL"
        text terms "NOT NULL"
        jsonb rows
        text response_message
        varchar_256 created_by "NOT NULL, default 'service-account'"
        timestamptz created_date "NOT NULL, default now()"
    }

    NLP2SQL_RESULT {
        bigint id PK
        bigint question_id FK
        text sql_text "NOT NULL"
        jsonb headers
        jsonb rows
        text response_message
        varchar_256 routing_class
        varchar_256 created_by "NOT NULL, default 'service-account'"
        timestamptz created_date "NOT NULL, default now()"
    }

    CHAT ||--o{ QUESTION : "chat_id, ON DELETE CASCADE"
    QUESTION ||--o{ DOCUMENT_RESULT : "question_id, ON DELETE CASCADE"
    QUESTION ||--o{ NLP2SQL_RESULT : "question_id, ON DELETE CASCADE"
```

Notes:
- All tables live in the `assistant` schema; each PK is `bigserial` backed by an explicit `..._id_seq` sequence.
- Indexes: `chat(user_id, modified_date DESC)`; `question(conversation_id)`, `question(conversation_id, user_id, created_date ASC)`, `question(chat_id, user_id, created_date ASC)`; `nlp2sql_result(question_id)`, `document_result(question_id)`.
- `question.chat_id → chat.id`, `document_result.question_id → question.id`, `nlp2sql_result.question_id → question.id`, all `ON DELETE CASCADE`.
