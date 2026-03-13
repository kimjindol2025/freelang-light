# 🎨 Grafana 모니터링 대시보드 설정

FreeLang Blog의 실시간 성능 모니터링을 위한 Grafana 대시보드 설정 가이드입니다.

## 🚀 빠른 시작

### 1. Docker로 Grafana 시작
```bash
docker-compose up -d grafana
```

### 2. Grafana 접속
- **URL**: http://localhost:3100
- **기본 계정**: admin / admin (설정에서 변경 권장)

### 3. Prometheus 데이터 소스 추가
1. 좌측 메뉴 → Configuration → Data Sources
2. Add Data Source → Prometheus
3. URL: `http://prometheus:9090`
4. Save & Test

### 4. 대시보드 임포트
```bash
# grafana-dashboards/freelang-blog-dashboard.json 파일을 Grafana에 임포트
1. Dashboards → Import
2. JSON 파일 선택 또는 URL 입력
3. Import
```

## 📊 제공되는 메트릭

### 1. API 성능
- **포스트 조회수**: 5분 평균 요청율
- **응답 시간**: P95 지표
- **에러율**: 5xx 에러 비율 (%)

### 2. 데이터베이스
- **연결 수**: 활성 PostgreSQL 연결
- **쿼리 시간**: 느린 쿼리 감지
- **테이블 크기**: 데이터베이스 용량

### 3. 캐시
- **Redis 히트율**: 캐시 효율 (%)
- **키 개수**: 캐시된 항목 수
- **메모리 사용**: Redis 메모리

### 4. 시스템
- **CPU 사용률**: 컨테이너 CPU (%)
- **메모리 사용**: 컨테이너 메모리 (MB)
- **디스크 I/O**: 초당 I/O 연산
- **네트워크**: 송수신 바이트

### 5. 비즈니스 메트릭
- **포스트 수**: 총 포스트 개수
- **활성 사용자**: 어제 로그인한 사용자
- **댓글 수**: 승인된 댓글 총수
- **평균 조회수**: 포스트당 평균

## 🎯 주요 쿼리 (Prometheus)

```promql
# API 요청율 (RPS)
rate(http_requests_total[5m])

# 평균 응답 시간
histogram_quantile(0.5, rate(http_request_duration_seconds_bucket[5m]))

# 에러 비율
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# 데이터베이스 연결
pg_stat_activity_count

# Redis 캐시 히트율
redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total)

# CPU 사용률
rate(container_cpu_usage_seconds_total[5m]) * 100

# 메모리 사용률
container_memory_usage_bytes / container_spec_memory_limit_bytes * 100
```

## ⚠️ 알림 (Alerts) 설정

### 알림 규칙 추가
Prometheus 설정 파일에서:

```yaml
alert_rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
    for: 5m
    annotations:
      summary: "High error rate detected ({{ $value | humanizePercentage }})"
      
  - alert: HighMemoryUsage
    expr: container_memory_usage_bytes > 400000000
    for: 10m
    annotations:
      summary: "High memory usage"
```

## 📈 대시보드 커스터마이징

### 패널 추가
1. Dashboard 우측 상단 → Add Panel
2. Metrics 선택 (Prometheus)
3. 쿼리 입력
4. Visualization 선택 (Graph, Gauge, Stat 등)
5. Save

### 자주 사용되는 Visualization
- **Graph**: 시계열 데이터 (API 응답 시간, CPU 사용률)
- **Gauge**: 백분율 (에러율, 캐시 히트율)
- **Stat**: 단일 값 (포스트 수, 연결 수)
- **Pie Chart**: 비율 (요청 상태 코드 분포)
- **Table**: 상세 데이터 (느린 쿼리 목록)

## 🔔 알림 채널 설정

### Slack 알림
1. Alerting → Notification channels
2. New channel → Slack
3. Webhook URL 입력
4. Test 및 Save

### 이메일 알림
1. Admin → Settings → SMTP
2. 이메일 설정 입력
3. Notification channels → Email 추가

## 🔒 보안

### 기본 설정 변경
```bash
# 관리자 비밀번호 변경
docker exec freelang-hybrid-grafana grafana-cli admin reset-admin-password <new_password>
```

### HTTPS 설정
```bash
# grafana.ini에서:
[server]
protocol = https
cert_file = /etc/grafana/certs/server.crt
cert_key = /etc/grafana/certs/server.key
```

## 📊 권장 대시보드 설정

### 개발 환경
- 새로고침: 30초
- 시간 범위: 1시간
- 상세도: 높음

### 프로덕션 환경
- 새로고침: 1분
- 시간 범위: 24시간
- 알림: 활성화

## 🆘 문제 해결

### Prometheus 연결 실패
```bash
# 1. Prometheus 서비스 상태 확인
docker ps | grep prometheus

# 2. 로그 확인
docker logs freelang-hybrid-prometheus

# 3. 네트워크 연결 확인
docker network inspect freelang-network
```

### 메트릭이 보이지 않음
```bash
# 1. Prometheus metrics 확인
curl http://localhost:9090/api/v1/targets

# 2. 쿼리 테스트
curl 'http://localhost:9090/api/v1/query?query=up'
```

## 📚 참고 자료

- [Grafana 공식 문서](https://grafana.com/docs/)
- [Prometheus 쿼리 언어](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana 플러그인](https://grafana.com/grafana/plugins)

---

**기본 계정**: admin / freelang123
**포트**: 3100
**시간대**: Asia/Seoul
