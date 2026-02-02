# Local Development Guide

## 개발 환경 구성

Xledger는 **Docker Compose 통합 DevContainer** 환경에서 개발합니다. DevContainer는 `dev` 서비스만 실행하며, 인프라 서비스는 필요할 때 프로파일로 별도 기동합니다.

### 아키텍처

```
┌─────────────────────────────────────────────┐
│ 호스트 (로컬 머신)                              │
│                                             │
│  Docker Daemon                              │
│  ├─ docker-compose.yml                      │
│  │  ├── dev (DevContainer)                  │
│  │  │   - Java 21, Gradle Wrapper           │
│  │  │   - 코드 작성 & 빌드                      │
│  │  │   - 테스트 실행                          │
│  │  │   - Docker socket 마운트                │
│  │  │                                       │
│  │  ├── postgres-account:5432               │
│  │  ├── postgres-cash:5432 (호스트:5433)      │
│  │  ├── postgres-ledger:5432 (호스트:5434)    │
│  │  ├── postgres-admin:5432 (호스트:5435)     │
│  │  ├── redis:6379                          │
│  │  ├── kafka:9092                          │
│  │  └── zookeeper:2181                      │
│  │                                          │
│  │  xledger-network (bridge)                │
│  │  └─ 모든 서비스 간 통신 가능                   │
│  │                                          │
│  └─ Testcontainers 네트워크 (격리)              │
│     └─ 테스트용 임시 컨테이너                     │
└─────────────────────────────────────────────┘
```

---

## 1. 빠른 시작

### 사전 요구사항
- Docker Desktop 또는 Docker Engine 설치
- Docker Compose V2 지원
- Visual Studio Code with Dev Containers 확장

### 시작 방법

1. **VS Code에서 프로젝트 열기**
2. **Command Palette** (`F1`) → **"Dev Containers: Reopen in Container"**
3. **자동으로 시작됨**:
   - DevContainer 빌드
   - Gradle wrapper 초기화
   - 포트 포워딩 설정

**그게 전부입니다!** 이제 개발할 준비가 되었습니다.

### 인프라 서비스 관리

DevContainer 외부에서 인프라 서비스를 시작/종료하려면:

```bash
# 인프라 서비스 시작 (볼륨 유지)
docker compose --project-name xledger --profile infra up -d

# 인프라 서비스 종료 (볼륨 유지)
docker compose --project-name xledger --profile infra down
```

```bash
# 호스트 터미널접속 정보

| 서비스 | DevContainer 내부 | 호스트 포트 | 환경변수 |
|--------|------------------|-----------|---------|
| PostgreSQL (account) | `postgres-account:5432` | 5432 | `POSTGRES_ACCOUNT_HOST` |
| PostgreSQL (cash) | `postgres-cash:5432` | 5433 | `POSTGRES_CASH_HOST` |
| PostgreSQL (ledger) | `postgres-ledger:5432` | 5434 | `POSTGRES_LEDGER_HOST` |
| PostgreSQL (admin) | `postgres-admin:5432` | 5435 | `POSTGRES_ADMIN_HOST` |
| Redis | `redis:6379` | 6379 | `REDIS_HOST` |
| Kafka | `kafka:9092` | 29092 | `KAFKA_BOOTSTRAP_SERVERS` |
| Zookeeper | `zookeeper:2181` | 2181 | - |

**접속 예시** (DevContainer 내부):
```properties
# application.yml 또는 application.properties
spring.datasource.url=jdbc:postgresql://${POSTGRES_ACCOUNT_HOST:postgres-account}:5432/xledger_account
spring.data.redis.host=${REDIS_HOST:redis}
spring.kafka.bootstrap-servers=${KAFKA_BOOTSTRAP_SERVERS:kafka:9092}
```

**호스트에서 접속** (데이터베이스 클라이언트 등):
```bash
psql -h localhost -p 5432 -U xledger -d xledger_account
```

| 서비스 | 포트 | 접속 URL (DevContainer 내부) |
|--------|------|------------------------------|
| Post개발 워크플로우
### 헬스체크

```bash
# PostgreSQL
docker compose --project-name xledger --profile infra exec postgres-account pg_isready -U xledger

# Redis
docker compose --project-name xledger --profile infra exec redis redis-cli ping

# Kafka
docker compose --project-name xledger --profile infra exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092
```

---

## 2. DevContainer 개발 (VS Code)

### 초기 설정
## Local Development Guide

이 문서는 Xledger 로컬 개발 환경 설정과 개발·테스트 워크플로우를 간결하고 일관되게 정리합니다.

---

## 요약
- 개발 환경: VS Code DevContainer (주 개발 환경)
- 인프라: 도커 컴포즈(`--profile infra`)로 관리 (Postgres, Redis, Kafka 등)
- 빌드/테스트: Gradle Wrapper (`./gradlew`)

권장: `docker compose` 명령 실행 시 `--project-name xledger` 옵션을 항상 지정하세요. 이렇게 하면 컨테이너 이름이 `xledger_<service>_1` 형식으로 고정되어 스크립트와 예제가 예측 가능합니다.

---

## 1. 사전 요구사항
- Docker Desktop 또는 Docker Engine
- Docker Compose V2 (docker CLI의 compose 서브커맨드)
- Visual Studio Code + Dev Containers 확장

---

## 2. 빠른 시작

1. VS Code로 레포지토리 열기
2. Command Palette (F1) → `Dev Containers: Reopen in Container`
3. 최초 빌드가 완료되면 DevContainer(`dev`)가 실행됩니다.

호스트에서 인프라만 기동하려면:

```bash
docker compose --project-name xledger --profile infra up -d
```

중지하려면:

```bash
docker compose --project-name xledger --profile infra down
```

---

## 3. 서비스 및 접속 정보

| 서비스 | 컨테이너 호스트명 | 기본 호스트 포트 |
|---|---:|---:|
| PostgreSQL (account) | postgres-account:5432 | 5432 |
| PostgreSQL (cash) | postgres-cash:5432 | 5433 |
| PostgreSQL (ledger) | postgres-ledger:5432 | 5434 |
| PostgreSQL (admin) | postgres-admin:5432 | 5435 |
| Redis | redis:6379 | 6379 |
| Kafka | kafka:9092 | 29092 (호스트 바인딩 시) |
| Zookeeper | zookeeper:2181 | 2181 |

application 설정 예:

```properties
spring.datasource.url=jdbc:postgresql://${POSTGRES_ACCOUNT_HOST:postgres-account}:5432/xledger_account
spring.data.redis.host=${REDIS_HOST:redis}
spring.kafka.bootstrap-servers=${KAFKA_BOOTSTRAP_SERVERS:kafka:9092}
```

호스트에서 DB 접속 예:

```bash
psql -h localhost -p 5432 -U xledger -d xledger_account
```

---

## 4. DevContainer 내 개발 명령

```bash
# 전체 빌드
./gradlew build

# 특정 모듈 빌드
./gradlew :libs:common:build

# 단위 테스트
./gradlew test

# 통합 테스트 (프로젝트 설정에 따라 이름이 다를 수 있음)
./gradlew integrationTest

# 서비스 실행 예
./gradlew :services:account-service:bootRun
```

컨테이너 내부에서 DB에 접근하려면:

```bash
docker exec -it <dev-container-name> psql -h postgres-account -p 5432 -U xledger -d xledger_account
```

DevContainer을 종료하려면 VS Code에서 `Close Remote Connection`을 선택하세요. 기본적으로 `dev` 서비스만 중지됩니다.

---

## 5. Testcontainers 사용

Testcontainers는 Docker 소켓 접근이 필요합니다. 로컬에서 실행하려면 DevContainer에 Docker 소켓을 바인드하거나(고급), CI에서 실행하는 것을 추천합니다.

`.devcontainer/devcontainer.json`에 소켓 마운트를 추가하면 로컬에서 Testcontainers를 바로 사용할 수 있습니다:

```json
"mounts": [
   "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
]
```

간단한 테스트코드 예 (Java):

```java
@Testcontainers
class AccountServiceIntegrationTest {
      @Container
      static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

      @DynamicPropertySource
      static void configureProperties(DynamicPropertyRegistry registry) {
            registry.add("spring.datasource.url", postgres::getJdbcUrl);
      }
}
```

---

## 6. DB 초기화 및 마이그레이션

초기 스크립트는 `scripts/db-init/` 아래에 모듈별로 정리되어 있습니다. 컨테이너에서 직접 실행하거나 호스트에서 psql로 접속해 적용하세요.

예:

```bash
docker exec -it $(docker compose --project-name xledger --profile infra ps -q postgres-account) psql -U xledger -d xledger_account -f /path/to/init.sql
```

---

## 7. 헬스체크 및 트러블슈팅

기본 점검 명령:

```bash
docker compose --project-name xledger --profile infra ps
docker compose --project-name xledger --profile infra logs -f postgres-account
docker compose --project-name xledger --profile infra exec postgres-account pg_isready -U xledger
docker compose --project-name xledger --profile infra exec redis redis-cli ping
```

문제가 있으면 순서대로:
1. 서비스 상태 확인
2. 로그 확인
3. 포트 충돌(`lsof -i :5432`) 확인
4. DevContainer 포트 포워딩 확인

포트 충돌 해결: docker-compose의 호스트 바인딩 포트를 변경하세요. 예: `15432:5432`.

Kafka는 Zookeeper 의존성으로 시작까지 30~60초가 소요될 수 있습니다. 로그에서 시작 메시지를 확인하세요.

---

## 8. 권장 워크플로우
1. 호스트에서 `docker compose --project-name xledger --profile infra up -d`로 인프라 실행
2. VS Code에서 DevContainer로 진입하여 개발
3. DevContainer에서 빌드/단위 테스트 실행
4. 통합 테스트 및 장기적인 검증은 CI에서 실행
5. 작업 종료 시 `docker compose --project-name xledger --profile infra down`으로 정리

---

## 참고 자료
- https://docs.docker.com/compose/
- https://code.visualstudio.com/docs/devcontainers/containers
- https://www.testcontainers.org/
