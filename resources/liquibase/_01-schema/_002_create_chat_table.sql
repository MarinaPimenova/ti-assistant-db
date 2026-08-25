-- chat

create table if not exists assistant.chat (
    id              bigserial                                          not null
        constraint pk_chat_id
            primary key,
    conversation_id uuid
        CONSTRAINT uniq_conversation_id UNIQUE,
    start_question  text,
    chat_name       varchar(100),
    user_id         varchar(100),
    created_by      varchar(256)             default 'service-account' not null,
    created_date    timestamp with time zone default CURRENT_TIMESTAMP not null,
    modified_by     varchar(256),
    modified_date   timestamp with time zone
);
CREATE SEQUENCE IF NOT EXISTS assistant.chat_id_seq AS BIGINT OWNED BY assistant.chat.id;
