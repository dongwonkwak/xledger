# Services

This directory will contain business service modules as they are implemented in each phase.

## Planned Services

### Phase 1: Core Ledger
- **ledger-service** - Double-entry bookkeeping, EOD reconciliation, reversals

### Phase 2: Cash & Exchange
- **account-service** - Account/customer management, authentication
- **cash-service** - Deposits, withdrawals, exchange, balance management

### Phase 3: Compliance & Operations
- **admin-service** - Operations portal, DLQ management, audit logs

## Module Naming Convention

Service modules follow the kebab-case convention:
- `ledger-service`
- `account-service`
- `cash-service`
- `admin-service`

Each service will have its own `build.gradle.kts` and standard Spring Boot application structure.
