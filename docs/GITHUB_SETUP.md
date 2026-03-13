# GitHub Actions 설정 가이드

## 1️⃣ SSH 키 생성

```bash
ssh-keygen -t ed25519 -f deploy_key -N ""
```

이 명령어는 두 개의 파일을 생성합니다:
- `deploy_key` (개인 키 - GitHub Secrets에 저장)
- `deploy_key.pub` (공개 키 - 서버에 설치)

## 2️⃣ 서버에 공개 키 설치

```bash
ssh -p 10053 kimjin@253.dclub.kr
mkdir -p ~/.ssh
cat >> ~/.ssh/authorized_keys << EOF
[deploy_key.pub의 내용]
