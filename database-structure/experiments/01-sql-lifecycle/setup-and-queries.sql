-- Run in an isolated PostgreSQL test database. This script resets public.users.
SELECT version();
SHOW server_version;
SHOW shared_buffers;
DROP TABLE IF EXISTS users;
CREATE TABLE users (id INTEGER, username TEXT, email TEXT);
INSERT INTO users (id, username, email)
SELECT i, 'user_' || i, 'user_' || i || '@example.com'
FROM generate_series(1, 100) AS i;
ANALYZE users;
-- A: small table, no index
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE id = 100;
INSERT INTO users (id, username, email)
SELECT i, 'user_' || i, 'user_' || i || '@example.com'
FROM generate_series(101, 1000000) AS i;
ANALYZE users;
-- B: large table, no index
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE id = 100;
CREATE INDEX idx_users_id ON users(id);
ANALYZE users;
-- C: large table, index, selective predicate
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE id = 100;
-- D: large table, index, nonselective predicate
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE id <= 900000;
