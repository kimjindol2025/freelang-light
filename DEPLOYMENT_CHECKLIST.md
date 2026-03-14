# 🚀 FreeLang 배포 체크리스트

## 1️⃣ 코드 준비 상태

✅ package.json 설정
✅ .env.production 설정
✅ docker-compose.yml 준비
✅ GitHub Actions workflows 설정
✅ OAuth 라우트 구현
✅ Admin Dashboard 구현
✅ 테스트 통과 (158개)
✅ 빌드 스크립트 준비

## 2️⃣ GitHub 설정 (필수)

⏳ Repository Settings → Secrets and variables에서 다음 추가:

```
DEPLOY_HOST          = 253.dclub.kr
DEPLOY_USER          = kimjin
DEPLOY_PORT          = 10053
DEPLOY_KEY           = SSH Private Key (base64)
DEPLOY_PATH          = /home/kimjin/freelang-light
SLACK_WEBHOOK_URL    = (선택) Slack 알림
NPM_TOKEN            = (선택) npm 패키지 발행

Google OAuth:
GOOGLE_CLIENT_ID     = xxx
GOOGLE_CLIENT_SECRET = xxx

GitHub OAuth:
GITHUB_CLIENT_ID     = xxx
GITHUB_CLIENT_SECRET = xxx

Naver OAuth:
NAVER_CLIENT_ID      = xxx
NAVER_CLIENT_SECRET  = xxx

Security:
JWT_SECRET           = (강력한 랜덤 키)
```

## 3️⃣ 배포 방법 선택

### Option A: GitHub Actions (자동, 권장) ⭐⭐⭐
```bash
git push origin master
# → 자동으로 test → build → deploy 실행
```

### Option B: 수동 배포
```bash
bash scripts/deploy-253.sh
# → 직접 SSH 연결해서 배포
```

### Option C: npm 패키지 발행
```bash
git tag v1.0.0 && git push origin --tags
# → npm에 자동 발행
```

## 4️⃣ 배포 후 검증

```bash
# 헬스 체크
curl https://253.dclub.kr/api/health

# 로그인 페이지 접속
https://253.dclub.kr

# 관리자 대시보드
https://253.dclub.kr/admin

# API 문서
https://253.dclub.kr/api/docs
```

## 5️⃣ 배포 상태 모니터링

```bash
# Docker 로그 확인
ssh -p 10053 kimjin@253.dclub.kr
docker-compose logs -f

# Prometheus 메트릭
https://253.dclub.kr:9090

# Grafana 대시보드
https://253.dclub.kr:3100 (admin/admin123)
```

---

## 📊 현재 상태

| 항목 | 상태 |
|------|------|
| 코드 준비 | ✅ 완료 |
| 테스트 | ✅ 158개 PASS |
| 문서 | ✅ 완료 |
| Docker | ✅ 준비 완료 |
| GitHub Actions | ✅ 설정 완료 |
| GitHub Secrets | ⏳ 입력 필요 |
| SSH 키 | ⏳ 입력 필요 |

---

## 🎯 다음 단계

1. GitHub Secrets 입력 (10분)
2. `git push origin master` 실행 (2분)
3. GitHub Actions 실행 자동 시작 (5-10분)
4. 배포 완료 후 https://253.dclub.kr 접속 (1분)

**총 소요시간: 약 20-30분**

