-- -- This table is written via INSERT and read by question_id:
-- --   where question_id = :questionId
-- -- So add a btree index on question_id to speed up lookups and the FK join.
CREATE INDEX IF NOT EXISTS idx_nlp2sql_result_question_id
    ON assistant.nlp2sql_result (question_id);

CREATE INDEX IF NOT EXISTS idx_document_result_question_id
    ON assistant.document_result (question_id);

