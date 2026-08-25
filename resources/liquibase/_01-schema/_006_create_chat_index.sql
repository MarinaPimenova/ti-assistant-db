-- Support getUserChats: filter by user_id + modified_date, order by modified_date desc
CREATE INDEX IF NOT EXISTS chat_user_id_modified_date_idx
    ON assistant.chat (user_id, modified_date DESC);

-- After creating indexes: update planner stats
ANALYZE assistant.chat;
