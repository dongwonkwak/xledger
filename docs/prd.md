# [PRD] Xledger

## Derivatives Ledger & Cash Management System

- 문서 버전: 1.1
- 작성일: 2026-01-27
- 작성자: Xledger Team (Architecture, Product, Security, SRE)

---

## 1. 프로젝트 개요 (Overview)

본 프로젝트(Xledger)는 파생상품 거래 환경에서 사용되는 원장(Ledger) 및 출납(Cash Management) 시스템을
현대적인 마이크로서비스 아키텍처로 재설계·구현하는 것을 목표로 한다.

기존 금융 시스템에서 널리 사용되던 레거시 기술 스택의 한계를 극복하고,
Java 21 기반의 고동시성 처리 모델과 복식부기(Double-Entry Accounting) 원리를 적용하여
극한의 데이터 정합성, 불변성, 그리고 고성능 트랜잭션 처리를 지향한다.

본 시스템은 특정 금융기관이나 조직에 종속되지 않는 범용 파생상품 원장 아키텍처를 목표로 하며,
실제 금융권 환경에서 요구되는 규제 준수, 감사 추적, 고가용성 요건을 충실히 반영한
포트폴리오 수준의 참조 구현(Reference Implementation)으로 설계된다.

---

## 2. 주요 기능 요구사항 (Functional Requirements)

### 2.1 계좌 및 고객 관리 (Account & Identity Management)

- FR-ACC-01: 계좌 개설/폐쇄 및 상태 이력 관리
- FR-ACC-02: 개인정보 필드 레벨 암호화 저장 (AES-256-GCM)
- FR-ACC-03: 주민번호/연락처 중복 검증을 위한 비가역 해시 컬럼 보유
- FR-ACC-04: 인증정보(PIN)는 단방향 해시(Argon2/bcrypt) 저장

### 2.2 출납 및 자금 관리 (Cash & Funds Management)

- FR-CASH-01: 실시간 입출금 및 즉시 원장 반영
- FR-CASH-02: KRW ↔ USD 환전 및 환율 스냅샷 저장
- FR-CASH-03: 자금 API Idempotency-Key 필수, 중복 요청 결과 캐시 응답

### 2.3 원장 관리 (Ledger – Core Financial Recording)

본 영역은 금융 시스템의 핵심 원장 기능을 담당하며,
기록, 정산, 정정, 보존, 재처리 책임을 논리적으로 포함한다.
아키텍처 설계 단계에서 처리 성격에 따라 별도 컴포넌트 또는 서비스로 분리될 수 있다.

- FR-LED-01: 복식부기 트랜잭션 기록
- FR-LED-02: 일일 대사 및 정산(EOD)
- FR-LED-03: UPDATE 금지, 역분개 기반 정정
- FR-LED-04: 데이터 아카이빙 및 보존 정책 (규제 기준에 따른 기간 설정)
- FR-LED-05: 이벤트 재처리 시 중복 전표 방지 (거래/이벤트 ID 기준)

### 2.4 대외 연계 및 컴플라이언스

본 영역은 외부 시스템 연계, 규제 대응, 이벤트 재처리를 포함하며,
향후 아키텍처 설계 단계에서 Integration / Compliance / Processing
관점으로 분리될 수 있다.

- FR-EXT-01: AML 이상 거래 이벤트 발행
- FR-EXT-02: 외부 체결 통지 기반 증거금 반영
- FR-EXT-03: 대외 이벤트 재처리/정합성 검증 절차 정의

### 2.5 운영자 포털 (Operations & Administration)

본 기능은 비즈니스 도메인의 핵심 로직을 포함하지 않으며,
원장 및 자금 도메인에서 발생한 데이터와 이벤트를
운영 및 감사 목적에서 조회·재처리·승인하기 위한 관리 인터페이스이다.

- FR-ADM-01: 원장 조회, 테스트 입출금, DLQ 재처리
- FR-ADM-02: 관리자 작업/재처리 감사 로그 및 승인 이력 기록

---

## 3. 비기능 요구사항 (Non-Functional Requirements)

### 3.1 성능

- Java 21 기반 고동시성 처리
- ≥ 1,000 TPS 원장 처리량
- 핫스팟 계좌 Lock 경합 최소화
- 계좌 단위 순서 보장 (Kafka Partition Key = accountId)
- 중복 전표 방지 위한 거래/이벤트 ID 유니크 보장

### 3.2 안정성 및 보안

- INSERT-ONLY Immutable Ledger
- Secret 환경 변수 주입
- Circuit Breaker, Retry, DLQ
- 모든 자금 API 멱등성 보장
- 이벤트 처리 중복 방지 (Idempotency + 이벤트 ID 기반 Dedup)
- 멱등성 키 TTL 기본 24시간, 동일 키 재요청 시 캐시 응답 반환
- 암호화 키 회전 및 접근 제어 (KMS/HSM 또는 동등 수준)
- 외부 연계/환율 API 타임아웃 및 지수 백오프 재시도

### 3.3 관측성

- ELK + OpenTelemetry + Prometheus/Grafana
- OpenTelemetry Trace Backend: Jaeger
- 로컬 Docker 환경 지원
- 감사 로그와 운영 로그 분리, 민감 정보 마스킹

### 3.4 감사 및 보존 정책

- 원장/이벤트/로그는 불변 저장을 원칙으로 하며, 삭제는 규제 승인 시에만 허용
- 보존 기간 기본값 (포트폴리오 기준): Hot 3개월, Warm 1년, Cold 5년 (환경별 조정 가능)
- 감사 추적에는 거래 생성/정정/취소의 원인, 수행자, 시각, 연관 이벤트 ID 포함
- 관리자 작업 및 DLQ 재처리 내역은 별도 감사 로그로 보관
- 아카이브 데이터는 WORM 수준 무결성 보장 스토리지로 이전

---

## 4. 기술적 제약사항

- Language: Java 21
- Framework: Spring Boot 3.4+
- Database: PostgreSQL 16+
- DB 전략: 모든 환경 동일 DB 엔진 사용, 서비스 간 직접 쿼리 금지
- Event Bus: Kafka
- Cache/Idempotency Store: Redis
- Infra: Docker Compose
- Test: JUnit 5, Testcontainers, k6

---

## 5. 로드맵

- Phase 0: Foundation
- Phase 1: Core Ledger (MVP)
- Phase 2: Cash & Exchange
- Phase 3: Future Optimization (Out of Scope for MVP)