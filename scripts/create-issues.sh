#!/bin/bash
# GitHub Issues 일괄 생성 스크립트

REPO="dongwonkwak/xledger"

# Phase 0: Foundation (Milestone #1)
echo "Creating Phase 0 issues..."

# P0-01: 프로젝트 초기 설정
gh issue create --repo $REPO --title "[P0-01-01] Gradle Kotlin DSL 멀티모듈 프로젝트 생성" --body "Java 21, Spring Boot 3.4 기반 Gradle Kotlin DSL 멀티모듈 프로젝트 초기 구조 생성

**예상 시간**: 2h
**의존성**: 없음" --label "type/infra,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-01-02] Version Catalog 설정 (libs.versions.toml)" --body "Gradle Version Catalog를 사용하여 의존성 버전 중앙 관리

**예상 시간**: 1h
**의존성**: P0-01-01" --label "type/infra,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-01-03] 공통 모듈 구조 정의" --body "common, domain, infra 등 공통 모듈 구조 정의

**예상 시간**: 1h
**의존성**: P0-01-02" --label "type/infra,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-01-04] 코드 스타일 설정 (Checkstyle, EditorConfig)" --body "코드 스타일 일관성을 위한 Checkstyle, EditorConfig 설정

**예상 시간**: 1h
**의존성**: P0-01-01" --label "type/infra,priority/high" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-01-05] Git 훅 설정 (pre-commit, commit-msg)" --body "pre-commit, commit-msg 훅 설정 (Conventional Commits 등)

**예상 시간**: 1h
**의존성**: P0-01-04" --label "type/infra,priority/high" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-01-06] CI 파이프라인 초기 구성 (GitHub Actions)" --body "GitHub Actions를 사용한 CI 파이프라인 초기 구성
- Build
- Test
- Lint check

**예상 시간**: 2h
**의존성**: P0-01-01" --label "type/infra,priority/high" --milestone "Phase 0: Foundation"

# P0-02: 개발 환경
gh issue create --repo $REPO --title "[P0-02-01] DevContainer 설정 (devcontainer.json, Dockerfile)" --body "VS Code / JetBrains Gateway용 DevContainer 설정

**예상 시간**: 2h
**의존성**: 없음" --label "type/infra,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-02-02] DevContainer에 Java 21, Gradle, Git, 확장 설정" --body "DevContainer에 필요한 도구 및 VS Code 확장 설정

**예상 시간**: 1h
**의존성**: P0-02-01" --label "type/infra,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-02-03] docker-compose.yml 작성 (PostgreSQL, Redis, Kafka)" --body "로컬 개발용 Docker Compose 설정
- PostgreSQL 16
- Redis 7
- Kafka + Zookeeper

**예상 시간**: 2h
**의존성**: P0-02-01" --label "type/infra,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-02-04] Observability 스택 추가 (Jaeger, Prometheus, Grafana)" --body "Docker Compose에 관측성 스택 추가
- Jaeger (Tracing)
- Prometheus (Metrics)
- Grafana (Dashboard)

**예상 시간**: 2h
**의존성**: P0-02-03" --label "type/infra,priority/high" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-02-05] 서비스별 DB 스키마 초기화 스크립트 작성" --body "서비스별 PostgreSQL 스키마 생성 초기화 스크립트

**예상 시간**: 2h
**의존성**: P0-02-03" --label "type/infra,priority/high" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-02-06] Kafka 토픽 자동 생성 스크립트 작성" --body "필요한 Kafka 토픽 자동 생성 스크립트

**예상 시간**: 1h
**의존성**: P0-02-03" --label "type/infra,priority/high" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-02-07] 로컬 환경 시작/종료 스크립트 (Makefile)" --body "개발 편의를 위한 Makefile 작성
- make up / make down
- make logs
- make reset

**예상 시간**: 1h
**의존성**: P0-02-06" --label "type/infra,priority/medium" --milestone "Phase 0: Foundation"

# P0-03: 공통 라이브러리
gh issue create --repo $REPO --title "[P0-03-01] 공통 예외 클래스 및 에러 코드 체계 구현" --body "도메인별 에러 코드 체계 및 공통 예외 클래스 구현

**에러 코드 체계**:
- ACC-1xx: Account
- CSH-1xx: Cash
- LED-1xx: Ledger
- SYS-5xx: System

**예상 시간**: 2h
**의존성**: P0-01-03" --label "type/feature,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-03-02] API 응답 표준 포맷 (ApiResponse, ErrorResponse)" --body "API 응답 표준 포맷 정의 및 구현

**예상 시간**: 1h
**의존성**: P0-03-01" --label "type/feature,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-03-03] 필드 암호화 유틸리티 (AES-256-GCM)" --body "개인정보 필드 레벨 암호화 유틸리티 구현
- AES-256-GCM 암호화/복호화
- 키 ID 관리 (키 회전 대비)

**예상 시간**: 3h
**의존성**: P0-01-03" --label "type/feature,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-03-04] 해시 유틸리티 (SHA-256, Argon2)" --body "해시 유틸리티 구현
- SHA-256 (검색용 비가역 해시)
- Argon2 (PIN 등 인증정보)

**예상 시간**: 2h
**의존성**: P0-01-03" --label "type/feature,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-03-05] Idempotency-Key 처리 필터/인터셉터" --body "멱등성 키 처리 공통 필터/인터셉터 구현
- Redis 기반 저장
- TTL 24시간
- 중복 요청 시 캐시 응답 반환

**예상 시간**: 3h
**의존성**: P0-01-03" --label "type/feature,priority/critical" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-03-06] OpenTelemetry 설정 및 커스텀 스팬 유틸리티" --body "OpenTelemetry 분산 추적 설정
- Jaeger 연동
- 커스텀 스팬 생성 유틸리티

**예상 시간**: 2h
**의존성**: P0-02-04" --label "type/feature,priority/high" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-03-07] 구조화 로깅 설정 (logback, 마스킹 필터)" --body "구조화 로깅 설정
- JSON 포맷 로깅
- 민감정보 마스킹 필터

**예상 시간**: 2h
**의존성**: P0-01-03" --label "type/feature,priority/high" --milestone "Phase 0: Foundation"

# P0-04: 테스트 인프라
gh issue create --repo $REPO --title "[P0-04-01] Testcontainers 베이스 설정" --body "Testcontainers 베이스 설정
- PostgreSQL
- Redis
- Kafka

**예상 시간**: 2h
**의존성**: P0-02-03" --label "type/test,priority/high" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-04-02] 테스트 픽스처 팩토리 기본 구조" --body "테스트 데이터 생성을 위한 픽스처 팩토리 구조 정의

**예상 시간**: 1h
**의존성**: P0-04-01" --label "type/test,priority/medium" --milestone "Phase 0: Foundation"

gh issue create --repo $REPO --title "[P0-04-03] 통합 테스트 베이스 클래스 작성" --body "통합 테스트용 베이스 클래스 작성
- Testcontainers 설정
- 공통 설정 상속

**예상 시간**: 1h
**의존성**: P0-04-01" --label "type/test,priority/medium" --milestone "Phase 0: Foundation"

echo "Phase 0 issues created!"

# Phase 1: Core Ledger (Milestone #2)
echo "Creating Phase 1 issues..."

# P1-01: Ledger Service 기본 구조
gh issue create --repo $REPO --title "[P1-01-01] ledger-service 모듈 생성" --body "ledger-service 모듈 생성 및 기본 설정

**예상 시간**: 1h
**의존성**: P0-01-03" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-01-02] Ledger 도메인 모델 구현 (JournalEntry, LedgerLine)" --body "복식부기 원장 도메인 모델 구현
- JournalEntry (전표)
- LedgerLine (전표 라인)

**예상 시간**: 3h
**의존성**: P1-01-01" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-01-03] Value Objects 구현 (JournalEntryId, Side, Currency)" --body "Ledger 도메인 Value Objects 구현

**예상 시간**: 2h
**의존성**: P1-01-02" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-01-04] 복식부기 밸런스 검증 로직 구현" --body "차변(Debit) = 대변(Credit) 검증 로직 구현

**예상 시간**: 2h
**의존성**: P1-01-02" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

# P1-02: Ledger Persistence
gh issue create --repo $REPO --title "[P1-02-01] Flyway 마이그레이션 설정 (Ledger)" --body "Ledger Service용 Flyway 마이그레이션 설정

**예상 시간**: 1h
**의존성**: P1-01-01" --label "type/infra,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-02-02] journal_entries 테이블 스키마 작성" --body "journal_entries 테이블 DDL 작성

**예상 시간**: 1h
**의존성**: P1-02-01" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-02-03] ledger_lines 테이블 스키마 작성" --body "ledger_lines 테이블 DDL 작성

**예상 시간**: 1h
**의존성**: P1-02-02" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-02-04] INSERT-ONLY 트리거 구현" --body "원장 불변성 보장을 위한 UPDATE/DELETE 방지 트리거 구현

**예상 시간**: 1h
**의존성**: P1-02-03" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-02-05] JournalEntryRepository 구현 (JPA)" --body "JournalEntry JPA Repository 구현

**예상 시간**: 2h
**의존성**: P1-02-04" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-02-06] 중복 전표 방지 (event_id 유니크 제약)" --body "event_id 기반 중복 전표 방지 구현

**예상 시간**: 1h
**의존성**: P1-02-05" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

# P1-03: Ledger API
gh issue create --repo $REPO --title "[P1-03-01] CreateJournalEntryCommand / Response DTO 정의" --body "전표 생성 Command/Response DTO 정의

**예상 시간**: 1h
**의존성**: P1-01-04" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-03-02] LedgerService 구현 (전표 생성)" --body "전표 생성 비즈니스 로직 구현

**예상 시간**: 3h
**의존성**: P1-02-05" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-03-03] POST /api/v1/ledger/entries 엔드포인트" --body "전표 생성 API 엔드포인트 구현

**예상 시간**: 2h
**의존성**: P1-03-02" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-03-04] GET /api/v1/ledger/entries/{id} 엔드포인트" --body "전표 단건 조회 API 엔드포인트 구현

**예상 시간**: 1h
**의존성**: P1-03-02" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-03-05] GET /api/v1/ledger/entries?accountId= 엔드포인트" --body "계좌별 전표 조회 API 엔드포인트 구현

**예상 시간**: 2h
**의존성**: P1-03-02" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

# P1-04: 역분개
gh issue create --repo $REPO --title "[P1-04-01] ReversalService 구현" --body "역분개 전표 생성 로직 구현
- 원본 전표 상쇄
- 정정 사유 기록

**예상 시간**: 3h
**의존성**: P1-03-02" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-04-02] POST /api/v1/ledger/entries/{id}/reverse 엔드포인트" --body "역분개 API 엔드포인트 구현

**예상 시간**: 2h
**의존성**: P1-04-01" --label "type/feature,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-04-03] 역분개 전표에 원본 참조 및 사유 기록" --body "역분개 전표에 원본 전표 ID, 정정 사유 기록

**예상 시간**: 1h
**의존성**: P1-04-01" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

# P1-05: Kafka 이벤트 발행
gh issue create --repo $REPO --title "[P1-05-01] Kafka Producer 설정 (Ledger)" --body "Ledger Service Kafka Producer 설정

**예상 시간**: 1h
**의존성**: P0-02-06" --label "type/infra,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-05-02] LedgerEvent 스키마 정의" --body "Ledger 도메인 이벤트 스키마 정의 (Avro/JSON)

**예상 시간**: 2h
**의존성**: P1-05-01" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-05-03] JournalEntryCreated 이벤트 발행 구현" --body "전표 생성 시 이벤트 발행 구현

**예상 시간**: 2h
**의존성**: P1-05-02" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-05-04] ReversalEntryCreated 이벤트 발행 구현" --body "역분개 생성 시 이벤트 발행 구현

**예상 시간**: 1h
**의존성**: P1-05-03" --label "type/feature,service/ledger,priority/medium" --milestone "Phase 1: Core Ledger (MVP)"

# P1-06: EOD 대사
gh issue create --repo $REPO --title "[P1-06-01] eod_reconciliations 테이블 스키마" --body "EOD 대사 결과 저장 테이블 스키마 작성

**예상 시간**: 1h
**의존성**: P1-02-01" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-06-02] EOD 대사 쿼리 구현" --body "일별 차변/대변 합계 검증 쿼리 구현

**예상 시간**: 2h
**의존성**: P1-06-01" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-06-03] ReconciliationService 구현" --body "EOD 대사 비즈니스 로직 구현

**예상 시간**: 3h
**의존성**: P1-06-02" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-06-04] POST /api/v1/ledger/eod/reconcile 엔드포인트" --body "EOD 대사 실행 API 엔드포인트 구현

**예상 시간**: 2h
**의존성**: P1-06-03" --label "type/feature,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-06-05] 불일치 시 알림 이벤트 발행" --body "대사 불일치 감지 시 알림 이벤트 발행

**예상 시간**: 1h
**의존성**: P1-06-04" --label "type/feature,service/ledger,priority/medium" --milestone "Phase 1: Core Ledger (MVP)"

# P1-07: Ledger 테스트
gh issue create --repo $REPO --title "[P1-07-01] 도메인 모델 단위 테스트 (밸런스 검증)" --body "복식부기 밸런스 검증 단위 테스트

**예상 시간**: 2h
**의존성**: P1-01-04" --label "type/test,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-07-02] Repository 통합 테스트" --body "JournalEntryRepository 통합 테스트

**예상 시간**: 2h
**의존성**: P1-02-06" --label "type/test,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-07-03] API 통합 테스트 (전표 생성/조회)" --body "Ledger API 통합 테스트

**예상 시간**: 3h
**의존성**: P1-03-05" --label "type/test,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-07-04] 역분개 통합 테스트" --body "역분개 기능 통합 테스트

**예상 시간**: 2h
**의존성**: P1-04-02" --label "type/test,service/ledger,priority/high" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-07-05] INSERT-ONLY 제약 테스트" --body "원장 불변성 제약 테스트

**예상 시간**: 1h
**의존성**: P1-02-04" --label "type/test,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

gh issue create --repo $REPO --title "[P1-07-06] 중복 전표 방지 테스트" --body "동일 event_id 중복 전표 방지 테스트

**예상 시간**: 1h
**의존성**: P1-02-06" --label "type/test,service/ledger,priority/critical" --milestone "Phase 1: Core Ledger (MVP)"

echo "Phase 1 issues created!"
echo "Phase 2 and Phase 3 issues will be created when needed."
echo "Total issues created: Phase 0 (24) + Phase 1 (31) = 55 issues"
