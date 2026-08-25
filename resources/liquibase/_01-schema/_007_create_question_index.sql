-- Support deleteAllByConversationId(conversationId)
CREATE INDEX IF NOT EXISTS question_conversation_id_idx
    ON assistant.question (conversation_id);

-- Support findAllByConversationIdAndUserIdOrderByCreatedDateAsc(conversationId, user_id)
CREATE INDEX IF NOT EXISTS question_conversation_user_id_created_date_idx
    ON assistant.question (conversation_id, user_id, created_date ASC);

CREATE INDEX IF NOT EXISTS question_chat_id_user_id_created_date_idx
    ON assistant.question (chat_id, user_id, created_date ASC);

-- After creating indexes: update planner stats
ANALYZE assistant.question;