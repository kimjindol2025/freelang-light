-- ============================================================================
-- FreeLang Blog - PostgreSQL Initialization Schema
-- ============================================================================
-- 용도: 블로그 데이터베이스 스키마 생성 및 인덱싱
-- 실행: docker-compose 시작시 자동 실행

-- ============================================================================
-- 1. 기본 테이블
-- ============================================================================

CREATE TABLE IF NOT EXISTS posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  description TEXT,
  content TEXT,
  author VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  published_at TIMESTAMPTZ,
  views INTEGER DEFAULT 0,
  likes INTEGER DEFAULT 0,
  is_published BOOLEAN DEFAULT FALSE,
  status VARCHAR(50) DEFAULT 'draft',
  tags TEXT[]
);

CREATE TABLE IF NOT EXISTS comments (
  id SERIAL PRIMARY KEY,
  post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author VARCHAR(100) NOT NULL,
  email VARCHAR(255),
  content TEXT NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  role VARCHAR(50) DEFAULT 'user',
  is_active BOOLEAN DEFAULT TRUE,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS oauth_users (
  id SERIAL PRIMARY KEY,
  provider VARCHAR(50) NOT NULL,
  provider_id VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  name VARCHAR(100),
  avatar_url TEXT,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(provider, provider_id)
);

-- ============================================================================
-- 2. 모니터링 & 통계 테이블
-- ============================================================================

CREATE TABLE IF NOT EXISTS view_stats (
  id SERIAL PRIMARY KEY,
  post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  viewer_ip VARCHAR(45),
  referer TEXT,
  user_agent TEXT,
  viewed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS search_logs (
  id SERIAL PRIMARY KEY,
  query VARCHAR(255),
  results_count INTEGER,
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  searched_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS error_logs (
  id SERIAL PRIMARY KEY,
  level VARCHAR(20),
  message TEXT,
  context JSONB,
  occurred_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS system_metrics (
  id SERIAL PRIMARY KEY,
  metric_name VARCHAR(100),
  metric_value FLOAT,
  tags JSONB,
  recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. Phase 3 추가: 캐시 & 성능 테이블
-- ============================================================================

CREATE TABLE IF NOT EXISTS cache_stats (
  id SERIAL PRIMARY KEY,
  cache_key VARCHAR(255),
  hits INTEGER DEFAULT 0,
  misses INTEGER DEFAULT 0,
  last_accessed TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS query_performance (
  id SERIAL PRIMARY KEY,
  query_name VARCHAR(255),
  execution_time_ms FLOAT,
  rows_affected INTEGER,
  executed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 4. 인덱싱 (Critical for Performance)
-- ============================================================================

-- Posts 인덱싱
CREATE INDEX idx_posts_published ON posts(is_published);
CREATE INDEX idx_posts_author ON posts(author);
CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_title ON posts USING GIN (to_tsvector('korean', title));
CREATE INDEX idx_posts_content ON posts USING GIN (to_tsvector('korean', content));

-- Comments 인덱싱
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_status ON comments(status);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);
CREATE INDEX idx_comments_post_status ON comments(post_id, status);

-- Users 인덱싱
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);

-- OAuth Users 인덱싱
CREATE INDEX idx_oauth_users_provider ON oauth_users(provider);
CREATE INDEX idx_oauth_users_user_id ON oauth_users(user_id);

-- View Stats 인덱싱
CREATE INDEX idx_view_stats_post_id ON view_stats(post_id);
CREATE INDEX idx_view_stats_viewed_at ON view_stats(viewed_at DESC);

-- Search Logs 인덱싱
CREATE INDEX idx_search_logs_query ON search_logs(query);
CREATE INDEX idx_search_logs_searched_at ON search_logs(searched_at DESC);

-- Error Logs 인덱싱
CREATE INDEX idx_error_logs_level ON error_logs(level);
CREATE INDEX idx_error_logs_occurred_at ON error_logs(occurred_at DESC);

-- ============================================================================
-- 5. 복합 인덱싱 (Multi-column)
-- ============================================================================

CREATE INDEX idx_posts_author_status ON posts(author, is_published, created_at DESC);
CREATE INDEX idx_comments_post_status ON comments(post_id, status, created_at DESC);

-- ============================================================================
-- 6. 뷰 (Views) - 복잡한 쿼리 단순화
-- ============================================================================

CREATE VIEW published_posts AS
  SELECT id, title, description, author, views, likes, created_at, updated_at
  FROM posts
  WHERE is_published = TRUE
  ORDER BY created_at DESC;

CREATE VIEW pending_comments AS
  SELECT id, post_id, author, content, created_at
  FROM comments
  WHERE status = 'pending'
  ORDER BY created_at ASC;

CREATE VIEW active_users AS
  SELECT id, username, email, role, created_at
  FROM users
  WHERE is_active = TRUE;

CREATE VIEW post_stats AS
  SELECT
    p.id,
    p.title,
    p.views,
    p.likes,
    COUNT(c.id) as comment_count,
    AVG(EXTRACT(EPOCH FROM (c.created_at - p.created_at))) as avg_comment_delay
  FROM posts p
  LEFT JOIN comments c ON p.id = c.post_id
  GROUP BY p.id;

-- ============================================================================
-- 7. 저장 프로시저 (Stored Procedures)
-- ============================================================================

-- 포스트 조회수 증가 (원자적)
CREATE OR REPLACE FUNCTION increment_post_views(p_post_id INTEGER)
RETURNS INTEGER AS $$
BEGIN
  UPDATE posts SET views = views + 1 WHERE id = p_post_id;
  RETURN (SELECT views FROM posts WHERE id = p_post_id);
END;
$$ LANGUAGE plpgsql;

-- 포스트 좋아요 증가
CREATE OR REPLACE FUNCTION increment_post_likes(p_post_id INTEGER)
RETURNS INTEGER AS $$
BEGIN
  UPDATE posts SET likes = likes + 1 WHERE id = p_post_id;
  RETURN (SELECT likes FROM posts WHERE id = p_post_id);
END;
$$ LANGUAGE plpgsql;

-- 댓글 개수 조회
CREATE OR REPLACE FUNCTION get_comment_count(p_post_id INTEGER)
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(*) FROM comments WHERE post_id = p_post_id AND status = 'approved');
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 8. 트리거 (Triggers) - 자동 업데이트
-- ============================================================================

-- 포스트 updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION update_posts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER posts_update_timestamp
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_posts_updated_at();

-- 댓글 updated_at 자동 업데이트
CREATE OR REPLACE FUNCTION update_comments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER comments_update_timestamp
  BEFORE UPDATE ON comments
  FOR EACH ROW
  EXECUTE FUNCTION update_comments_updated_at();

-- ============================================================================
-- 9. 초기 데이터 (옵션)
-- ============================================================================

-- 기본 사용자
INSERT INTO users (username, email, password_hash, role, is_active)
VALUES (
  'admin',
  'admin@freelang.local',
  '$2b$10$...',  -- bcrypt hashed password
  'admin',
  TRUE
) ON CONFLICT (email) DO NOTHING;

-- ============================================================================
-- 10. 권한 설정
-- ============================================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON posts TO freelang;
GRANT SELECT, INSERT, UPDATE, DELETE ON comments TO freelang;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO freelang;
GRANT SELECT, INSERT, UPDATE, DELETE ON oauth_users TO freelang;
GRANT SELECT, INSERT ON view_stats TO freelang;
GRANT SELECT, INSERT ON search_logs TO freelang;
GRANT SELECT, INSERT ON error_logs TO freelang;
GRANT SELECT, INSERT ON system_metrics TO freelang;

-- ============================================================================
-- 11. 통계 & 쿼리 최적화
-- ============================================================================

-- 테이블 분석 (쿼리 플래너 최적화)
ANALYZE posts;
ANALYZE comments;
ANALYZE users;
ANALYZE oauth_users;

-- VACUUM (블로트 정리)
VACUUM ANALYZE posts;
VACUUM ANALYZE comments;

-- ============================================================================
-- Schema Version (마이그레이션 추적)
-- ============================================================================

CREATE TABLE IF NOT EXISTS schema_version (
  version INTEGER PRIMARY KEY,
  description VARCHAR(255),
  executed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO schema_version (version, description)
VALUES (1, 'Initial schema with indexing and views')
ON CONFLICT DO NOTHING;
