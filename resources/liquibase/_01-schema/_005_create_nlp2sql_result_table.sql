-- nlp2sql_result

create table if not exists assistant.nlp2sql_result (
    id               bigserial                                          not null
        constraint pk_nlp2sql_result_id
            primary key,
    question_id      bigint                                             not null,
    sql_text         text                                               not null,
    headers          jsonb,
    rows             jsonb,
    response_message text,
    routing_class    varchar(256),
    created_by       varchar(256)             default 'service-account' not null,
    created_date     timestamp with time zone default CURRENT_TIMESTAMP not null,
    CONSTRAINT fk_nlp2sql_question
        FOREIGN KEY (question_id)
            REFERENCES assistant.question (id) ON DELETE CASCADE
);
CREATE SEQUENCE IF NOT EXISTS assistant.nlp2sql_result_id_seq AS BIGINT OWNED BY assistant.nlp2sql_result.id;
