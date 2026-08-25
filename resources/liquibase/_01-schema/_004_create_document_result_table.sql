-- document_result

create table if not exists assistant.document_result (
    id               bigserial                                          not null
        constraint pk_document_result_id
            primary key,
    question_id      bigint                                             not null,
    sql_text         text                                               not null,
    terms            text                                               not null,
    rows             jsonb,
    response_message text,
    created_by       varchar(256)             default 'service-account' not null,
    created_date     timestamp with time zone default CURRENT_TIMESTAMP not null,
    CONSTRAINT fk_document_question
        FOREIGN KEY (question_id)
            REFERENCES assistant.question (id) ON DELETE CASCADE

);
CREATE SEQUENCE IF NOT EXISTS assistant.document_result_id_seq AS BIGINT OWNED BY assistant.document_result.id;
