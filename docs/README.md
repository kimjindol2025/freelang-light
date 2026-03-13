# FreeLang Blog API Documentation

## 📡 API 개요

FreeLang Blog API는 프로덕션급 REST API로 블로그 포스트, 댓글, 사용자, 분석 기능을 제공합니다.

### 기본 정보
- **Base URL**: `http://localhost:5021/api` (개발)
- **Base URL**: `https://253.dclub.kr/api` (프로덕션)
- **인증**: JWT (Bearer Token)
- **요청/응답 형식**: JSON

## 🚀 빠른 시작

### 1. Swagger UI 접속
```
http://localhost:5021/api/docs
```

Swagger UI에서 모든 엔드포인트를 인터랙티브하게 테스트할 수 있습니다.

### 2. OpenAPI 스펙 다운로드
```
GET http://localhost:5021/api/docs/spec
```

OpenAPI 3.0 YAML 형식의 완전한 API 스펙입니다.

## 📚 API 엔드포인트

### Posts (포스트)

#### 포스트 목록 조회
```http
GET /api/blogs?page=1&limit=10&status=published
```

**응답 예시**:
```json
{
  "posts": [
    {
      "id": 1,
      "title": "FreeLang 소개",
      "description": "FreeLang 언어의 특징",
      "author": "kim",
      "created_at": "2026-03-12T10:30:00Z",
      "views": 150,
      "status": "published"
    }
  ],
  "total": 42,
  "page": 1,
  "pages": 5
}
```

#### 포스트 생성
```http
POST /api/blogs
Authorization: Bearer eyJhbGc...

{
  "title": "새로운 포스트",
  "description": "설명",
  "content": "내용...",
  "tags": ["freeLang", "tutorial"]
}
```

#### 포스트 상세 조회
```http
GET /api/blogs/1
```

#### 포스트 수정
```http
PUT /api/blogs/1
Authorization: Bearer eyJhbGc...

{
  "title": "수정된 제목",
  "status": "published"
}
```

#### 포스트 삭제
```http
DELETE /api/blogs/1
Authorization: Bearer eyJhbGc...
```

#### 조회수 증가
```http
POST /api/blogs/1/view
```

### Comments (댓글)

#### 댓글 목록
```http
GET /api/comments?post_id=1&status=approved
```

#### 댓글 생성
```http
POST /api/comments

{
  "post_id": 1,
  "author": "John Doe",
  "content": "좋은 글이네요!"
}
```

#### 댓글 승인/거부
```http
PUT /api/comments/5
Authorization: Bearer eyJhbGc...

{
  "status": "approved"
}
```

#### 댓글 삭제
```http
DELETE /api/comments/5
Authorization: Bearer eyJhbGc...
```

### Users (사용자)

#### 사용자 목록
```http
GET /api/users
Authorization: Bearer eyJhbGc...
```

#### 사용자 정보
```http
GET /api/users/10
Authorization: Bearer eyJhbGc...
```

#### 사용자 역할 변경
```http
PUT /api/users/10
Authorization: Bearer eyJhbGc...

{
  "role": "editor"
}
```

### Auth (인증)

#### Google OAuth 로그인
```http
GET /auth/google/login
```

응답: OAuth 인증 URL

```json
{
  "auth_url": "https://accounts.google.com/o/oauth2/v2/auth?..."
}
```

#### Google OAuth 콜백
```http
GET /auth/google/callback?code=...&state=...
```

응답: JWT 토큰

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "google_123456",
    "email": "user@gmail.com",
    "name": "John Doe"
  }
}
```

#### GitHub OAuth 로그인
```http
GET /auth/github/login
```

#### Naver OAuth 로그인
```http
GET /auth/naver/login
```

### Analytics (분석)

#### 통계 조회
```http
GET /api/admin/stats
Authorization: Bearer eyJhbGc...
```

응답:
```json
{
  "total_posts": 42,
  "total_comments": 156,
  "total_users": 23,
  "total_views": 5421
}
```

#### 시스템 상태
```http
GET /api/admin/health
```

응답:
```json
{
  "status": "healthy",
  "memory_usage": 45.2,
  "disk_usage": 62.1,
  "database_connections": 3,
  "uptime_seconds": 86400
}
```

#### 백업 트리거
```http
POST /api/admin/backup
Authorization: Bearer eyJhbGc...
```

응답:
```json
{
  "backup_id": "bkp_20260312_143000",
  "status": "started"
}
```

#### 에러 로그
```http
GET /api/admin/logs?level=ERROR&limit=50
Authorization: Bearer eyJhbGc...
```

## 🔐 인증 (JWT)

### Bearer Token 사용법

모든 보호된 엔드포인트에서 Authorization 헤더가 필요합니다:

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

### 토큰 예시

```json
{
  "sub": "user_123",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "editor",
  "iat": 1678600000,
  "exp": 1678686400
}
```

## 📊 응답 형식

### 성공 응답 (200)
```json
{
  "id": 1,
  "title": "포스트 제목",
  "status": "published"
}
```

### 에러 응답
```json
{
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

### 상태 코드

| 코드 | 의미 |
|------|------|
| 200 | OK - 성공 |
| 201 | Created - 생성됨 |
| 204 | No Content - 삭제됨 |
| 400 | Bad Request - 요청 오류 |
| 401 | Unauthorized - 인증 실패 |
| 403 | Forbidden - 권한 없음 |
| 404 | Not Found - 리소스 없음 |
| 429 | Too Many Requests - 레이트 제한 |
| 500 | Internal Server Error - 서버 오류 |

## 🔄 레이트 제한

기본적으로 IP당 분당 100 요청으로 제한됩니다.

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1678600060
```

## 🧪 테스트

### cURL로 테스트
```bash
# 포스트 목록 조회
curl -X GET http://localhost:5021/api/blogs

# 포스트 생성 (인증 필요)
curl -X POST http://localhost:5021/api/blogs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"New Post","content":"..."}'
```

### JavaScript로 테스트
```javascript
// 포스트 목록 조회
fetch('http://localhost:5021/api/blogs')
  .then(res => res.json())
  .then(data => console.log(data))

// 포스트 생성
fetch('http://localhost:5021/api/blogs', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    title: 'New Post',
    content: '...'
  })
})
```

### Postman 사용
1. Postman 열기
2. Import → Raw text 선택
3. OpenAPI 스펙 복사/붙여넣기: `GET http://localhost:5021/api/docs/spec`
4. Generate Postman Collection

## 📖 추가 리소스

- [OpenAPI 스펙](./api.yaml)
- [Swagger UI](http://localhost:5021/api/docs)
- [GitHub 저장소](https://github.com/freelang-light/freelang)
- [기술 블로그](https://blog.freelang-light.com)

## 🤝 지원

문제가 발생하면:
1. [GitHub Issues](https://github.com/freelang-light/freelang/issues)에 보고
2. [Slack 커뮤니티](https://freelang-light.slack.com)에서 질문
3. [이메일](mailto:support@freelang-light.com) 문의

---

마지막 업데이트: 2026-03-12
API 버전: 1.0.0
