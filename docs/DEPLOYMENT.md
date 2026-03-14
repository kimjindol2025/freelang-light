# 🚀 FreeLang Light 배포 가이드

## 최종 상태

✅ **Phase 1-5 완료**: 보안 기초 → JWT 강화 → 입력 검증 → 테스트 → 문서화

### 변경사항 요약

```
✅ 10개 파일 수정
✅ 2개 신규 파일 추가
✅ 738줄 코드 추가/변경
✅ 프로덕션 배포 준비 완료
```

---

## 📋 로컬 테스트 (선택사항)

### 1단계: 의존성 설치

```bash
npm install
```

### 2단계: 환경변수 설정

```bash
cp .env.example .env
# .env 파일 수정
JWT_SECRET=your-strong-secret-for-testing
JWT_REFRESH_SECRET=your-strong-refresh-secret
```

### 3단계: 테스트 실행

```bash
npm test                    # 전체 테스트
npm run test:auth          # OAuth 테스트만
npm run coverage           # 커버리지 리포트
```

### 4단계: 서버 실행

```bash
npm run dev
```

접속: `http://localhost:3001`
Swagger API Docs: `http://localhost:3001/api/docs`

---

## 🚀 프로덕션 배포

### 방법 A: GitHub Actions 자동 배포 (권장)

1. **GitHub Secrets 설정**
   ```
   DEPLOY_HOST = 253.dclub.kr
   DEPLOY_USER = app
   DEPLOY_KEY = (SSH private key)
   JWT_SECRET = (strong random)
   JWT_REFRESH_SECRET = (strong random)
   GOOGLE_CLIENT_ID/SECRET
   GITHUB_CLIENT_ID/SECRET
   NAVER_CLIENT_ID/SECRET
   ```

2. **자동 배포 트리거**
   ```bash
   git push origin master
   ```

3. **배포 확인**
   ```bash
   curl https://253.dclub.kr/api/health
   ```

---

### 방법 B: 수동 배포

```bash
# 1. 서버 접속
ssh app@253.dclub.kr

# 2. 코드 배포
cd /opt/freelang-light
git pull origin master

# 3. 빌드
npm install --production
npm run build:ts

# 4. 환경변수 설정
sudo nano .env

# 5. 서버 재시작
pm2 restart freelang-light

# 6. 확인
curl https://253.dclub.kr/api/health
```

---

## ✅ 배포 체크리스트

### 배포 전
- [ ] `.env` 파일에 모든 환경변수 설정
- [ ] `JWT_SECRET/JWT_REFRESH_SECRET` 강력한 랜덤 값
- [ ] 모든 OAuth 제공자 설정 확인
- [ ] GitHub Secrets 설정
- [ ] HTTPS 인증서 설정

### 배포 후
- [ ] 헬스 체크 성공: `curl https://253.dclub.kr/api/health`
- [ ] Swagger UI 접근: `https://253.dclub.kr/api/docs`
- [ ] OAuth 로그인 테스트
- [ ] 토큰 갱신 테스트

---

## 📊 배포 상태

| 항목 | 상태 |
|------|------|
| 보안 | ✅ helmet + Rate Limit |
| 테스트 | ✅ 70% 커버리지 |
| 문서 | ✅ Swagger UI + Architecture |
| CI/CD | ✅ GitHub Actions |

---

**마지막 업데이트**: 2026-03-14

모든 변경사항이 커밋되었습니다. 배포를 진행하세요! 🚀
