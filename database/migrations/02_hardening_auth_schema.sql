-- -----------------------------------------------------------------------------
-- 1. Tokens: guardar el HASH SHA-256, nunca el token original
-- -----------------------------------------------------------------------------
-- Los tokens existentes estaban en texto plano: se invalidan todos.
DELETE FROM verification_tokens;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_name = 'verification_tokens' AND column_name = 'token') THEN
        ALTER TABLE verification_tokens RENAME COLUMN token TO token_hash;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_tokens_token') THEN
        ALTER TABLE verification_tokens RENAME CONSTRAINT uq_tokens_token TO uq_tokens_token_hash;
    END IF;
END $$;

ALTER TABLE verification_tokens ALTER COLUMN token_hash TYPE CHAR(64);

-- -----------------------------------------------------------------------------
-- 2. Índices: eliminar duplicados (UNIQUE ya crea su propio índice B-Tree)
-- -----------------------------------------------------------------------------
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_tokens_token;
CREATE INDEX IF NOT EXISTS idx_tokens_user_id ON verification_tokens(user_id);