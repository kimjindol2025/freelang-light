# GitHub Actions 배포 설정

## 1. SSH 키 생성
ssh-keygen -t ed25519 -f deploy_key -N ""

## 2. 서버에 공개 키 추가
cat deploy_key.pub >> ~/.ssh/authorized_keys on 253.dclub.kr

## 3. GitHub Secrets 추가
- DEPLOY_KEY: deploy_key 개인 키 내용
- DEPLOY_HOST: 253.dclub.kr
- DEPLOY_PORT: 10053
- DEPLOY_USER: kimjin
- DEPLOY_PATH: /home/kimjin/freelang-light
- SLACK_WEBHOOK_URL: (선택) Slack 웹훅

## 4. 배포 실행
git push origin master

자동으로 test.yml → deploy.yml 순서로 실행됩니다.
