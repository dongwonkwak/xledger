# Design - Xledger

- 문서 버전: 1.1
- 작성일: 2026-01-29
- 기준 PRD: v1.1
- 기준 Requirements: v1.0

---

## 1. 아키텍처 개요

### 1.1 시스템 컨텍스트

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           External Systems                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                   │
│  │ Trading      │  │ Exchange     │  │ AML/         │                   │
│  │ System       │  │ Rate API     │  │ Compliance   │                   │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                   │
└─────────┼─────────────────┼─────────────────┼───────────────────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           Xledger System                                 │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                        API Gateway                               │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│          │                 │                 │                           │
│          ▼                 ▼                 ▼                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                   │
│  │ Account      │  │ Cash         │  │ Ledger       │                   │
│  │ Service      │  │ Service      │  │ Service      │                   │
│  └──────────────┘  └──────────────┘  └──────────────┘                   │
│          │                 │                 │                           │
│          ▼                 ▼                 ▼                           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                     Kafka (Event Bus)                            │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│          │                 │                 │                           │
│          ▼                 ▼                 ▼                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                   │
│  │ PostgreSQL   │  │ Redis        │  │ Observability│                   │
│  │ (Per-Service)│  │ (Cache/Idem) │  │ Stack        │                   │
│  └──────────────┘  └──────────────┘  └──────────────┘                   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 서비스 구성

| 서비스 | 책임 | 데이터 소유권 |
|--------|------|---------------|
| **account-service** | 계좌 생성/폐쇄, 고객 정보 관리, 인증 | accounts, customers |
| **cash-service** | 입출금, 환전, 잔액 관리 | balances, transactions |
| **ledger-service** | 복식부기 전표 기록, EOD 정산, 역분개 | journal_entries, ledger_lines |
| **admin-service** | 운영자 포털, DLQ 관리, 감사 로그 조회 | admin_audit_logs |

### 1.3 기술 스택

| 계층 | 기술 |
|------|------|
| Language | Java 21 (Virtual Threads) |
| Framework | Spring Boot 3.4+ |
| Build | Gradle 8.x (Kotlin DSL + Version Catalog) |
| Database | PostgreSQL 16+ (서비스별 스키마 분리) |
| Event Bus | Kafka 3.x |
| Cache | Redis 7.x |
| Observability | OpenTelemetry, Jaeger, Prometheus, Grafana, ELK |
| Dev Environment | DevContainer (VS Code / JetBrains Gateway) |
| Infra | Docker Compose |
| Test | JUnit 5, Testcontainers, k6 |

---

## 2. 서비스 상세 설계

### 2.1 Account Service

#### 2.1.1 도메인 모델

```java
// Account Aggregate
public record Account(
    AccountId id,
    CustomerId customerId,
    AccountStatus status,
    Currency currency,
    Instant createdAt,
    Instant updatedAt
) {}

public enum AccountStatus {
    PENDING, ACTIVE, SUSPENDED, CLOSED
}

// Customer Entity
public record Customer(
    CustomerId id,
    EncryptedField name,           // AES-256-GCM
    EncryptedField address,        // AES-256-GCM
    EncryptedField phone,          // AES-256-GCM
    HashedField ssnHash,           // SHA-256 (검색용)
    HashedField phoneHash,         // SHA-256 (중복검증용)
    HashedField pinHash,           // Argon2
    Instant createdAt
) {}
```

#### 2.1.2 API 설계

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/v1/accounts` | 계좌 개설 |
| GET | `/api/v1/accounts/{accountId}` | 계좌 조회 |
| PATCH | `/api/v1/accounts/{accountId}/status` | 상태 변경 |
| POST | `/api/v1/accounts/{accountId}/close` | 계좌 폐쇄 |
| POST | `/api/v1/auth/verify-pin` | PIN 검증 |

#### 2.1.3 이벤트

| 이벤트 | 토픽 | 설명 |
|--------|------|------|
| AccountCreated | `account.events` | 계좌 생성 완료 |
| AccountStatusChanged | `account.events` | 상태 변경 |
| AccountClosed | `account.events` | 계좌 폐쇄 |

---

### 2.2 Cash Service

#### 2.2.1 도메인 모델

```java
// Balance Aggregate
public record Balance(
    BalanceId id,
    AccountId accountId,
    Currency currency,
    BigDecimal available,
    BigDecimal pending,
    Long version                    // Optimistic Locking
) {}

// Transaction Entity
public record CashTransaction(
    TransactionId id,
    AccountId accountId,
    TransactionType type,           // DEPOSIT, WITHDRAWAL, EXCHANGE
    Currency currency,
    BigDecimal amount,
    String idempotencyKey,
    TransactionStatus status,
    Instant createdAt
) {}
```

#### 2.2.2 API 설계

| Method | Endpoint | 설명 | 헤더 |
|--------|----------|------|------|
| POST | `/api/v1/cash/deposit` | 입금 | `Idempotency-Key` (필수) |
| POST | `/api/v1/cash/withdraw` | 출금 | `Idempotency-Key` (필수) |
| POST | `/api/v1/cash/exchange` | 환전 | `Idempotency-Key` (필수) |
| GET | `/api/v1/cash/balance/{accountId}` | 잔액 조회 | - |

#### 2.2.3 멱등성 처리 흐름

```
┌─────────┐     ┌─────────────┐     ┌─────────┐     ┌──────────┐
│ Client  │────▶│ Cash Service│────▶│ Redis   │     │ Ledger   │
└─────────┘     └─────────────┘     └─────────┘     │ Service  │
                      │                   │          └──────────┘
                      │  1. Check Key     │                │
                      │──────────────────▶│                │
                      │                   │                │
                      │  2a. Key exists   │                │
                      │◀──────────────────│                │
                      │  → Return cached  │                │
                      │                   │                │
                      │  2b. Key not found│                │
                      │◀──────────────────│                │
                      │                   │                │
                      │  3. Process tx    │                │
                      │─────────────────────────────────▶  │
                      │                   │                │
                      │  4. Store result  │                │
                      │  (TTL: 24h)       │                │
                      │──────────────────▶│                │
                      │                   │                │
```

#### 2.2.4 이벤트

| 이벤트 | 토픽 | 설명 |
|--------|------|------|
| DepositCompleted | `cash.events` | 입금 완료 |
| WithdrawalCompleted | `cash.events` | 출금 완료 |
| ExchangeCompleted | `cash.events` | 환전 완료 |
| InsufficientBalance | `cash.events` | 잔액 부족 발생 |

---

### 2.3 Ledger Service

#### 2.3.1 도메인 모델

```java
// JournalEntry Aggregate (복식부기 전표)
public record JournalEntry(
    JournalEntryId id,
    String eventId,                 // 중복 방지용 유니크 키
    String transactionRef,          // 원거래 참조
    JournalEntryType type,          // NORMAL, REVERSAL, CORRECTION
    JournalEntryId reversedEntryId, // 역분개 시 원본 참조
    String description,
    List<LedgerLine> lines,
    Instant createdAt
) {
    public void validate() {
        BigDecimal debitSum = lines.stream()
            .filter(l -> l.side() == Side.DEBIT)
            .map(LedgerLine::amount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal creditSum = lines.stream()
            .filter(l -> l.side() == Side.CREDIT)
            .map(LedgerLine::amount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        if (debitSum.compareTo(creditSum) != 0) {
            throw new UnbalancedEntryException(debitSum, creditSum);
        }
    }
}

// LedgerLine (전표 라인)
public record LedgerLine(
    LedgerLineId id,
    AccountId accountId,
    String ledgerAccountCode,       // 계정과목 코드
    Side side,                      // DEBIT, CREDIT
    Currency currency,
    BigDecimal amount,
    Instant createdAt
) {}

public enum Side { DEBIT, CREDIT }
```

#### 2.3.2 API 설계

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/v1/ledger/entries` | 전표 기록 (내부 전용) |
| GET | `/api/v1/ledger/entries/{entryId}` | 전표 조회 |
| GET | `/api/v1/ledger/entries?accountId=` | 계좌별 전표 조회 |
| POST | `/api/v1/ledger/entries/{entryId}/reverse` | 역분개 생성 |
| POST | `/api/v1/ledger/eod/reconcile` | EOD 대사 실행 |

#### 2.3.3 INSERT-ONLY 정책

```sql
-- 원장 테이블에 UPDATE/DELETE 트리거 방지
CREATE OR REPLACE FUNCTION prevent_ledger_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Ledger entries are immutable. Use reversal entries for corrections.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ledger_immutable_trigger
BEFORE UPDATE OR DELETE ON journal_entries
FOR EACH ROW EXECUTE FUNCTION prevent_ledger_modification();

CREATE TRIGGER ledger_line_immutable_trigger
BEFORE UPDATE OR DELETE ON ledger_lines
FOR EACH ROW EXECUTE FUNCTION prevent_ledger_modification();
```

#### 2.3.4 이벤트

| 이벤트 | 토픽 | 설명 |
|--------|------|------|
| JournalEntryCreated | `ledger.events` | 전표 생성 |
| ReversalEntryCreated | `ledger.events` | 역분개 생성 |
| EODReconciliationCompleted | `ledger.events` | EOD 대사 완료 |
| ReconciliationMismatch | `ledger.events` | 대사 불일치 감지 |

---

### 2.4 Admin Service

#### 2.4.1 API 설계

| Method | Endpoint | 설명 | 권한 |
|--------|----------|------|------|
| GET | `/api/v1/admin/ledger/entries` | 원장 조회 | ADMIN |
| POST | `/api/v1/admin/cash/test-deposit` | 테스트 입금 | ADMIN |
| GET | `/api/v1/admin/dlq/messages` | DLQ 메시지 조회 | ADMIN |
| POST | `/api/v1/admin/dlq/messages/{id}/retry` | DLQ 재처리 | ADMIN |
| GET | `/api/v1/admin/audit-logs` | 감사 로그 조회 | AUDITOR |

#### 2.4.2 감사 로그 모델

```java
public record AuditLog(
    AuditLogId id,
    String action,
    String performedBy,
    String targetResource,
    String targetId,
    Map<String, Object> details,
    String ipAddress,
    String approvedBy,              // 승인이 필요한 작업
    Instant approvedAt,
    Instant createdAt
) {}
```

---

## 3. 데이터 모델

### 3.1 Account Service Schema

```sql
-- customers
CREATE TABLE customers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_encrypted  BYTEA NOT NULL,             -- AES-256-GCM
    address_encrypted BYTEA,
    phone_encrypted BYTEA,
    ssn_hash        VARCHAR(64) UNIQUE,         -- SHA-256
    phone_hash      VARCHAR(64),                -- SHA-256
    pin_hash        VARCHAR(128) NOT NULL,      -- Argon2
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- accounts
CREATE TABLE accounts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id     UUID NOT NULL REFERENCES customers(id),
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    currency        VARCHAR(3) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- account_status_history
CREATE TABLE account_status_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id      UUID NOT NULL REFERENCES accounts(id),
    previous_status VARCHAR(20),
    new_status      VARCHAR(20) NOT NULL,
    reason          TEXT,
    changed_by      VARCHAR(100),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_accounts_status ON accounts(status);
CREATE INDEX idx_status_history_account ON account_status_history(account_id);
```

### 3.2 Cash Service Schema

```sql
-- balances
CREATE TABLE balances (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id      UUID NOT NULL,
    currency        VARCHAR(3) NOT NULL,
    available       DECIMAL(18,4) NOT NULL DEFAULT 0,
    pending         DECIMAL(18,4) NOT NULL DEFAULT 0,
    version         BIGINT NOT NULL DEFAULT 0,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(account_id, currency)
);

-- cash_transactions
CREATE TABLE cash_transactions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id      UUID NOT NULL,
    type            VARCHAR(20) NOT NULL,       -- DEPOSIT, WITHDRAWAL, EXCHANGE
    currency        VARCHAR(3) NOT NULL,
    amount          DECIMAL(18,4) NOT NULL,
    idempotency_key VARCHAR(64) NOT NULL UNIQUE,
    status          VARCHAR(20) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- exchange_rates (환율 스냅샷)
CREATE TABLE exchange_rates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency   VARCHAR(3) NOT NULL,
    to_currency     VARCHAR(3) NOT NULL,
    rate            DECIMAL(18,8) NOT NULL,
    captured_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_balances_account ON balances(account_id);
CREATE INDEX idx_transactions_account ON cash_transactions(account_id);
CREATE INDEX idx_transactions_idempotency ON cash_transactions(idempotency_key);
```

### 3.3 Ledger Service Schema

```sql
-- journal_entries
CREATE TABLE journal_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id        VARCHAR(64) NOT NULL UNIQUE,    -- 중복 방지
    transaction_ref VARCHAR(64),
    type            VARCHAR(20) NOT NULL,           -- NORMAL, REVERSAL, CORRECTION
    reversed_entry_id UUID REFERENCES journal_entries(id),
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ledger_lines
CREATE TABLE ledger_lines (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id),
    account_id      UUID NOT NULL,
    ledger_account_code VARCHAR(20) NOT NULL,
    side            VARCHAR(10) NOT NULL,           -- DEBIT, CREDIT
    currency        VARCHAR(3) NOT NULL,
    amount          DECIMAL(18,4) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- eod_reconciliation
CREATE TABLE eod_reconciliations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_date   DATE NOT NULL UNIQUE,
    total_debit     DECIMAL(18,4) NOT NULL,
    total_credit    DECIMAL(18,4) NOT NULL,
    status          VARCHAR(20) NOT NULL,           -- BALANCED, MISMATCHED
    mismatch_details JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_entries_event ON journal_entries(event_id);
CREATE INDEX idx_entries_created ON journal_entries(created_at);
CREATE INDEX idx_lines_entry ON ledger_lines(journal_entry_id);
CREATE INDEX idx_lines_account ON ledger_lines(account_id);
```

### 3.4 Admin Service Schema

```sql
-- admin_audit_logs
CREATE TABLE admin_audit_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action          VARCHAR(100) NOT NULL,
    performed_by    VARCHAR(100) NOT NULL,
    target_resource VARCHAR(100),
    target_id       VARCHAR(100),
    details         JSONB,
    ip_address      VARCHAR(45),
    approved_by     VARCHAR(100),
    approved_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_action ON admin_audit_logs(action);
CREATE INDEX idx_audit_performed_by ON admin_audit_logs(performed_by);
CREATE INDEX idx_audit_created ON admin_audit_logs(created_at);
```

---

## 4. 이벤트 아키텍처

### 4.1 Kafka 토픽 설계

| 토픽 | Partition Key | Retention | 설명 |
|------|---------------|-----------|------|
| `account.events` | accountId | 7 days | 계좌 도메인 이벤트 |
| `cash.events` | accountId | 7 days | 자금 도메인 이벤트 |
| `ledger.events` | accountId | 30 days | 원장 도메인 이벤트 |
| `aml.events` | accountId | 90 days | AML 이상거래 이벤트 |
| `*.dlq` | - | 30 days | Dead Letter Queue |

### 4.2 이벤트 스키마 (예시)

```json
{
  "eventId": "evt_abc123",
  "eventType": "DepositCompleted",
  "aggregateId": "acc_xyz789",
  "aggregateType": "CashTransaction",
  "timestamp": "2026-01-29T10:30:00Z",
  "version": 1,
  "payload": {
    "transactionId": "txn_def456",
    "accountId": "acc_xyz789",
    "amount": 1000000,
    "currency": "KRW"
  },
  "metadata": {
    "correlationId": "corr_123",
    "causationId": "cmd_456",
    "userId": "user_789"
  }
}
```

---

## 5. 에러 처리

### 5.1 에러 코드 체계

| 코드 범위 | 도메인 | 예시 |
|-----------|--------|------|
| ACC-1xx | Account | ACC-101: 계좌 없음 |
| ACC-2xx | Account | ACC-201: 중복 SSN |
| CSH-1xx | Cash | CSH-101: 잔액 부족 |
| CSH-2xx | Cash | CSH-201: 환율 조회 실패 |
| LED-1xx | Ledger | LED-101: 밸런스 불일치 |
| LED-2xx | Ledger | LED-201: 중복 이벤트 |
| SYS-5xx | System | SYS-501: 내부 오류 |

### 5.2 에러 응답 형식

```json
{
  "error": {
    "code": "CSH-101",
    "message": "Insufficient balance",
    "details": {
      "available": 50000,
      "requested": 100000,
      "currency": "KRW"
    },
    "traceId": "abc123def456"
  }
}
```

### 5.3 재시도 정책

| 실패 유형 | 재시도 | 백오프 | DLQ |
|-----------|--------|--------|-----|
| 일시적 네트워크 오류 | 3회 | 지수 (1s, 2s, 4s) | ✓ |
| DB 커넥션 실패 | 5회 | 지수 (500ms~) | ✓ |
| 외부 API 타임아웃 | 3회 | 지수 (2s, 4s, 8s) | ✓ |
| 비즈니스 로직 오류 | 0회 | - | ✗ |
| 데이터 검증 오류 | 0회 | - | ✗ |

---

## 6. 보안 설계

### 6.1 암호화 키 관리

```yaml
# 개발/로컬 환경: 환경변수
ENCRYPTION_KEY_ID: "local-dev-key-001"
ENCRYPTION_KEY: "${XLEDGER_ENCRYPTION_KEY}"

# 프로덕션: KMS/HSM 통합 (예시)
encryption:
  provider: aws-kms  # 또는 vault, hsm
  key-id: "alias/xledger-pii-key"
  rotation-period: 90d
```

### 6.2 필드 레벨 암호화

```java
@Service
public class FieldEncryptionService {
    
    public EncryptedField encrypt(String plaintext) {
        byte[] iv = generateSecureRandom(12);
        byte[] ciphertext = aesGcmEncrypt(plaintext, currentKey, iv);
        return new EncryptedField(
            currentKeyId,
            Base64.encode(iv),
            Base64.encode(ciphertext)
        );
    }
    
    public String decrypt(EncryptedField field) {
        Key key = keyStore.getKey(field.keyId());
        return aesGcmDecrypt(field.ciphertext(), key, field.iv());
    }
}
```

---

## 7. 관측성 설계

### 7.1 분산 추적

```java
// OpenTelemetry 자동 계측 + 커스텀 스팬
@Traced
public JournalEntry createEntry(CreateEntryCommand cmd) {
    Span span = tracer.spanBuilder("ledger.createEntry")
        .setAttribute("account.id", cmd.accountId())
        .setAttribute("event.id", cmd.eventId())
        .startSpan();
    
    try (Scope scope = span.makeCurrent()) {
        // 비즈니스 로직
    } finally {
        span.end();
    }
}
```

### 7.2 메트릭

| 메트릭 | 타입 | 설명 |
|--------|------|------|
| `ledger_entries_total` | Counter | 생성된 전표 수 |
| `ledger_entry_duration_seconds` | Histogram | 전표 생성 소요 시간 |
| `cash_balance_available` | Gauge | 계좌별 가용 잔액 |
| `kafka_consumer_lag` | Gauge | 컨슈머 지연 |
| `circuit_breaker_state` | Gauge | 서킷 브레이커 상태 |

### 7.3 로깅

```java
// 구조화된 로깅 with 민감정보 마스킹
log.info("Deposit completed", 
    kv("transactionId", txn.id()),
    kv("accountId", mask(txn.accountId())),  // acc_***789
    kv("amount", txn.amount()),
    kv("currency", txn.currency())
);
```

---

## 8. 테스트 전략

### 8.1 테스트 피라미드

| 레벨 | 커버리지 목표 | 도구 |
|------|---------------|------|
| Unit | 80%+ | JUnit 5, Mockito |
| Integration | 핵심 경로 | Testcontainers |
| Contract | 서비스 간 API | Spring Cloud Contract |
| E2E | 주요 시나리오 | Testcontainers, REST Assured |
| Performance | TPS 검증 | k6 |

### 8.2 Testcontainers 구성

```java
@Testcontainers
class LedgerServiceIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");
    
    @Container
    static KafkaContainer kafka = new KafkaContainer(DockerImageName.parse("confluentinc/cp-kafka:7.5.0"));
    
    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7")
        .withExposedPorts(6379);
}
```

### 8.3 성능 테스트 시나리오

```javascript
// k6 스크립트 예시
export const options = {
    scenarios: {
        ledger_load: {
            executor: 'constant-arrival-rate',
            rate: 1000,
            duration: '5m',
            preAllocatedVUs: 100,
        },
    },
    thresholds: {
        http_req_duration: ['p(95)<100'],
        http_req_failed: ['rate<0.01'],
    },
};
```

---

## 9. 배포 구성 (Docker Compose)

```yaml
version: '3.9'
services:
  # --- Databases ---
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: xledger
      POSTGRES_USER: xledger
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  # --- Kafka ---
  kafka:
    image: confluentinc/cp-kafka:7.5.0
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"

  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  # --- Observability ---
  jaeger:
    image: jaegertracing/all-in-one:1.50
    ports:
      - "16686:16686"
      - "4317:4317"

  prometheus:
    image: prom/prometheus:v2.47.0
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:10.1.0
    ports:
      - "3000:3000"

volumes:
  postgres_data:
```

---

## Appendix: 결정 기록 (Decision Log)

### DR-001: INSERT-ONLY 원장

- **결정**: 원장 테이블에 UPDATE/DELETE 금지, DB 트리거로 강제
- **근거**: 금융 감사 요건 충족, 데이터 무결성 보장
- **영향**: 정정 시 역분개 전표 필수, 스토리지 증가
- **검토**: N/A (핵심 원칙)

### DR-002: 서비스별 DB 스키마 분리

- **결정**: 각 서비스가 자체 스키마 소유, 직접 쿼리 금지
- **근거**: 마이크로서비스 독립성 확보, 스키마 변경 영향 격리
- **영향**: 서비스 간 데이터 조회 시 API 호출 필요
- **검토**: N/A

### DR-003: Kafka Partition Key = accountId

- **결정**: 모든 토픽에서 accountId를 파티션 키로 사용
- **근거**: 계좌 단위 이벤트 순서 보장, 핫스팟 분산
- **영향**: 특정 계좌 이벤트는 단일 파티션에 집중
- **검토**: 핫스팟 계좌 모니터링 필요

### DR-004: Gradle Kotlin DSL + Version Catalog

- **결정**: Groovy DSL 대신 Kotlin DSL 사용, libs.versions.toml로 버전 중앙 관리
- **근거**: 타입 안전성, IDE 자동완성 지원, 의존성 버전 일관성 확보
- **영향**: Kotlin DSL 학습 필요, 기존 Groovy 스크립트 마이그레이션 불필요(신규 프로젝트)
- **검토**: N/A

### DR-005: DevContainer 개발 환경

- **결정**: DevContainer를 표준 개발 환경으로 채택 (VS Code, JetBrains Gateway 지원)
- **근거**: 개발 환경 일관성 보장, Java 21/Gradle 버전 차이로 인한 이슈 방지
- **영향**: 컨테이너 오버헤드 존재 (Apple Silicon에서 양호), Docker 필수
- **검토**: 성능 이슈 발생 시 네이티브 개발 환경 병행 허용

### DR-006: GitHub Flow 브랜치 전략

- **결정**: GitHub Flow 채택 (main + feature 브랜치)
- **근거**: 1인 개발/소규모 팀에 적합, 지속 배포 친화적, 단순한 워크플로우
- **영향**: 복잡한 릴리스 관리 불필요, PR 기반 코드 리뷰
- **브랜치 네이밍**:
  - `feature/{task-id}-{description}` — 기능 개발
  - `fix/{task-id}-{description}` — 버그 수정
  - `docs/{description}` — 문서 수정
- **머지 전략**: Squash Merge, PR 머지 후 브랜치 삭제
- **릴리스**: Phase 완료 시 태그 (v0.1.0-phase0, v1.0.0-mvp)
- **검토**: N/A
