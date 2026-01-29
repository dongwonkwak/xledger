# Requirements - Xledger

- 문서 버전: 1.0
- 작성일: 2026-01-29
- 기준 PRD: v1.1

---

## 1. 계좌 및 고객 관리 (Account & Identity Management)

### FR-ACC-01: 계좌 개설/폐쇄 및 상태 이력 관리

| ID | EARS 요구사항 |
|---|---|
| FR-ACC-01-01 | WHEN 고객이 계좌 개설을 요청하면, THE SYSTEM SHALL 새 계좌를 생성하고 `ACTIVE` 상태로 초기화해야 한다. |
| FR-ACC-01-02 | WHEN 계좌 폐쇄가 요청되면, THE SYSTEM SHALL 계좌 상태를 `CLOSED`로 변경하고 폐쇄 사유 및 시각을 기록해야 한다. |
| FR-ACC-01-03 | WHEN 계좌 상태가 변경될 때마다, THE SYSTEM SHALL 변경 이력(이전 상태, 새 상태, 변경 시각, 변경 사유)을 불변 로그로 저장해야 한다. |

### FR-ACC-02: 개인정보 필드 레벨 암호화

| ID | EARS 요구사항 |
|---|---|
| FR-ACC-02-01 | THE SYSTEM SHALL 개인정보 필드(이름, 주소, 연락처 등)를 AES-256-GCM으로 암호화하여 저장해야 한다. |
| FR-ACC-02-02 | WHEN 개인정보 조회가 요청되면, THE SYSTEM SHALL 복호화 권한을 검증한 후 복호화된 값을 반환해야 한다. |

### FR-ACC-03: 중복 검증용 해시

| ID | EARS 요구사항 |
|---|---|
| FR-ACC-03-01 | WHEN 계좌 개설 시, THE SYSTEM SHALL 주민번호/연락처의 비가역 해시를 생성하여 중복 여부를 검증해야 한다. |
| FR-ACC-03-02 | IF 동일 해시가 이미 존재하면, THE SYSTEM SHALL 계좌 개설을 거부하고 중복 오류를 반환해야 한다. |

### FR-ACC-04: 인증정보 저장

| ID | EARS 요구사항 |
|---|---|
| FR-ACC-04-01 | THE SYSTEM SHALL PIN을 Argon2 또는 bcrypt로 단방향 해시하여 저장해야 한다. |
| FR-ACC-04-02 | WHEN PIN 검증 요청 시, THE SYSTEM SHALL 입력값을 해시 후 저장된 해시와 비교하여 일치 여부를 반환해야 한다. |

---

## 2. 출납 및 자금 관리 (Cash & Funds Management)

### FR-CASH-01: 실시간 입출금

| ID | EARS 요구사항 |
|---|---|
| FR-CASH-01-01 | WHEN 입금 요청이 수신되면, THE SYSTEM SHALL 해당 계좌의 잔액을 증가시키고 원장에 복식부기 전표를 즉시 기록해야 한다. |
| FR-CASH-01-02 | WHEN 출금 요청이 수신되면, THE SYSTEM SHALL 잔액 충분 여부를 검증하고, 충분하면 잔액을 차감하고 원장에 복식부기 전표를 즉시 기록해야 한다. |
| FR-CASH-01-03 | IF 출금 요청 시 잔액이 부족하면, THE SYSTEM SHALL 출금을 거부하고 잔액 부족 오류를 반환해야 한다. |

### FR-CASH-02: 환전 (KRW ↔ USD)

| ID | EARS 요구사항 |
|---|---|
| FR-CASH-02-01 | WHEN 환전 요청이 수신되면, THE SYSTEM SHALL 현재 환율을 조회하고 스냅샷을 저장한 뒤 환전을 실행해야 한다. |
| FR-CASH-02-02 | THE SYSTEM SHALL 환전 시 적용된 환율, 원화/달러 금액, 수수료를 전표에 기록해야 한다. |

### FR-CASH-03: 멱등성 보장

| ID | EARS 요구사항 |
|---|---|
| FR-CASH-03-01 | THE SYSTEM SHALL 모든 자금 API 요청에 `Idempotency-Key` 헤더를 필수로 요구해야 한다. |
| FR-CASH-03-02 | IF 동일한 Idempotency-Key로 재요청이 들어오면, THE SYSTEM SHALL 기존 처리 결과를 캐시에서 반환해야 한다. |
| FR-CASH-03-03 | THE SYSTEM SHALL Idempotency-Key를 24시간 TTL로 Redis에 저장해야 한다. |

---

## 3. 원장 관리 (Ledger)

### FR-LED-01: 복식부기 트랜잭션 기록

| ID | EARS 요구사항 |
|---|---|
| FR-LED-01-01 | WHEN 거래가 발생하면, THE SYSTEM SHALL 차변(Debit)과 대변(Credit)의 합이 일치하는 복식부기 전표를 생성해야 한다. |
| FR-LED-01-02 | IF 차변과 대변의 합이 불일치하면, THE SYSTEM SHALL 전표 생성을 거부하고 밸런스 오류를 발생시켜야 한다. |

### FR-LED-02: 일일 대사 및 정산 (EOD)

| ID | EARS 요구사항 |
|---|---|
| FR-LED-02-01 | WHEN 영업일 마감 시점에, THE SYSTEM SHALL 당일 모든 전표의 차변/대변 총합 일치를 검증해야 한다. |
| FR-LED-02-02 | IF 대사 불일치가 발견되면, THE SYSTEM SHALL 불일치 내역을 기록하고 알림을 발생시켜야 한다. |

### FR-LED-03: UPDATE 금지, 역분개 기반 정정

| ID | EARS 요구사항 |
|---|---|
| FR-LED-03-01 | THE SYSTEM SHALL 원장 테이블에 UPDATE/DELETE 연산을 금지해야 한다 (INSERT-ONLY). |
| FR-LED-03-02 | WHEN 전표 정정이 필요하면, THE SYSTEM SHALL 기존 전표를 상쇄하는 역분개 전표를 생성하고, 정정된 내용으로 새 전표를 기록해야 한다. |
| FR-LED-03-03 | THE SYSTEM SHALL 역분개 전표에 원본 전표 ID와 정정 사유를 참조로 기록해야 한다. |

### FR-LED-04: 데이터 아카이빙 및 보존

| ID | EARS 요구사항 |
|---|---|
| FR-LED-04-01 | THE SYSTEM SHALL 원장 데이터를 Hot(3개월) / Warm(1년) / Cold(5년) 티어로 분류하여 보존해야 한다. |
| FR-LED-04-02 | WHEN 보존 기간이 경과하면, THE SYSTEM SHALL 데이터를 다음 티어로 이전하거나 WORM 스토리지로 아카이브해야 한다. |

### FR-LED-05: 중복 전표 방지

| ID | EARS 요구사항 |
|---|---|
| FR-LED-05-01 | THE SYSTEM SHALL 거래 ID 또는 이벤트 ID를 유니크 키로 관리하여 중복 전표 생성을 방지해야 한다. |
| FR-LED-05-02 | IF 동일 거래/이벤트 ID로 전표 생성이 시도되면, THE SYSTEM SHALL 기존 전표를 반환하고 중복 생성을 건너뛰어야 한다. |

---

## 4. 대외 연계 및 컴플라이언스

### FR-EXT-01: AML 이상 거래 이벤트

| ID | EARS 요구사항 |
|---|---|
| FR-EXT-01-01 | WHEN 이상 거래 패턴이 감지되면, THE SYSTEM SHALL AML 이벤트를 Kafka 토픽으로 발행해야 한다. |
| FR-EXT-01-02 | THE SYSTEM SHALL AML 이벤트에 거래 ID, 계좌 ID, 금액, 감지 규칙, 발생 시각을 포함해야 한다. |

### FR-EXT-02: 외부 체결 통지 기반 증거금 반영

| ID | EARS 요구사항 |
|---|---|
| FR-EXT-02-01 | WHEN 외부 시스템에서 체결 통지가 수신되면, THE SYSTEM SHALL 해당 계좌의 증거금을 조정하고 원장에 기록해야 한다. |

### FR-EXT-03: 대외 이벤트 재처리

| ID | EARS 요구사항 |
|---|---|
| FR-EXT-03-01 | WHEN 이벤트 처리 실패 시, THE SYSTEM SHALL DLQ(Dead Letter Queue)로 이동시키고 실패 사유를 기록해야 한다. |
| FR-EXT-03-02 | THE SYSTEM SHALL DLQ 이벤트에 대해 수동/자동 재처리 기능을 제공해야 한다. |

---

## 5. 운영자 포털 (Operations & Administration)

### FR-ADM-01: 원장 조회 및 운영 기능

| ID | EARS 요구사항 |
|---|---|
| FR-ADM-01-01 | THE SYSTEM SHALL 관리자에게 계좌별/기간별/거래유형별 원장 조회 기능을 제공해야 한다. |
| FR-ADM-01-02 | THE SYSTEM SHALL 관리자 권한으로 테스트 입출금을 실행할 수 있는 기능을 제공해야 한다. |
| FR-ADM-01-03 | THE SYSTEM SHALL 관리자에게 DLQ 메시지 조회 및 재처리 기능을 제공해야 한다. |

### FR-ADM-02: 감사 로그

| ID | EARS 요구사항 |
|---|---|
| FR-ADM-02-01 | WHEN 관리자가 작업을 수행하면, THE SYSTEM SHALL 작업 내용, 수행자, 시각, IP를 감사 로그로 기록해야 한다. |
| FR-ADM-02-02 | THE SYSTEM SHALL 재처리/정정 작업에 대해 승인자 정보와 승인 시각을 별도로 기록해야 한다. |

---

## 6. 비기능 요구사항 (Non-Functional Requirements)

### NFR-PERF: 성능

| ID | EARS 요구사항 |
|---|---|
| NFR-PERF-01 | THE SYSTEM SHALL 원장 트랜잭션을 ≥ 1,000 TPS로 처리할 수 있어야 한다. |
| NFR-PERF-02 | THE SYSTEM SHALL 핫스팟 계좌에 대한 Lock 경합을 최소화하는 동시성 제어를 구현해야 한다. |
| NFR-PERF-03 | THE SYSTEM SHALL Kafka Partition Key를 accountId로 설정하여 계좌 단위 순서를 보장해야 한다. |

### NFR-SEC: 보안

| ID | EARS 요구사항 |
|---|---|
| NFR-SEC-01 | THE SYSTEM SHALL 암호화 키를 KMS/HSM 또는 동등 수준으로 관리하고 주기적으로 회전해야 한다. |
| NFR-SEC-02 | THE SYSTEM SHALL Secret을 환경 변수로 주입받아야 하며, 코드/설정 파일에 하드코딩하지 않아야 한다. |

### NFR-RES: 안정성

| ID | EARS 요구사항 |
|---|---|
| NFR-RES-01 | THE SYSTEM SHALL 외부 연계 호출에 Circuit Breaker 패턴을 적용해야 한다. |
| NFR-RES-02 | THE SYSTEM SHALL 실패한 외부 호출에 지수 백오프(Exponential Backoff) 재시도를 적용해야 한다. |
| NFR-RES-03 | IF 재시도 후에도 실패하면, THE SYSTEM SHALL 해당 이벤트를 DLQ로 이동시켜야 한다. |

### NFR-OBS: 관측성

| ID | EARS 요구사항 |
|---|---|
| NFR-OBS-01 | THE SYSTEM SHALL OpenTelemetry 기반 분산 추적을 제공해야 한다 (Trace Backend: Jaeger). |
| NFR-OBS-02 | THE SYSTEM SHALL Prometheus 메트릭을 노출하고 Grafana 대시보드를 제공해야 한다. |
| NFR-OBS-03 | THE SYSTEM SHALL 감사 로그와 운영 로그를 분리하고, 민감 정보를 마스킹해야 한다. |

### NFR-AUD: 감사 및 보존

| ID | EARS 요구사항 |
|---|---|
| NFR-AUD-01 | THE SYSTEM SHALL 원장/이벤트/로그를 불변 저장해야 하며, 삭제는 규제 승인 시에만 허용해야 한다. |
| NFR-AUD-02 | THE SYSTEM SHALL 감사 추적에 거래의 원인, 수행자, 시각, 연관 이벤트 ID를 포함해야 한다. |
| NFR-AUD-03 | THE SYSTEM SHALL 아카이브 데이터를 WORM(Write Once Read Many) 무결성 보장 스토리지로 이전해야 한다. |

---

## Appendix: 용어 정의

| 용어 | 정의 |
|---|---|
| 복식부기 | 모든 거래를 차변(Debit)과 대변(Credit)으로 동시에 기록하는 회계 방식 |
| 역분개 | 기존 전표의 차변/대변을 반대로 기록하여 상쇄하는 정정 방식 |
| Idempotency-Key | 동일 요청의 중복 처리를 방지하기 위한 고유 식별자 |
| DLQ | Dead Letter Queue, 처리 실패한 메시지를 보관하는 큐 |
| EOD | End of Day, 영업일 마감 정산 프로세스 |
| WORM | Write Once Read Many, 한 번 쓰면 수정 불가한 저장소 |
