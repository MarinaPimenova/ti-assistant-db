-- question

create table if not exists assistant.question (
    id                 bigserial                                          not null
        constraint pk_question_id
            primary key,
    chat_id            bigint                                             not null,
    conversation_id    uuid                                               not null,
    user_id            varchar(100),
    question           text                                               not null,
    agent_name_list    varchar(1024),
    llm_response       text,
    source_list        jsonb,
    document_list      jsonb,
    user_feedback      varchar(50),
    status             varchar(100)
        CHECK (status IN ('created', 'in progress', 'failed', 'completed', 'canceled', 'timed out', 'integration error'))
                                                DEFAULT 'created'         NOT NULL,
    follow_up_question text,
    created_by         varchar(256)             default 'service-account' not null,
    created_date       timestamp with time zone default CURRENT_TIMESTAMP not null,
    modified_by        varchar(256),
    modified_date      timestamp with time zone,
    CONSTRAINT fk_chat
        FOREIGN KEY (chat_id)
            REFERENCES assistant.chat (id) ON DELETE CASCADE
);
CREATE SEQUENCE IF NOT EXISTS assistant.question_id_seq AS BIGINT OWNED BY assistant.question.id;
