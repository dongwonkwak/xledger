# Xledger

Derivatives Ledger & Cash Management System

## Overview

Xledger is a modern microservices-based ledger and cash management system designed for derivatives trading environments. Built with Java 21 and Spring Boot 3.4, it implements double-entry accounting principles with a focus on data integrity, immutability, and high-performance transaction processing.

This is a portfolio-level reference implementation that adheres to financial industry compliance, audit trail, and high availability requirements.

## Features

- **Immutable Ledger** - INSERT-ONLY ledger with reversal-based corrections
- **Double-Entry Accounting** - Automatic debit/credit balance validation
- **Event-Driven Architecture** - Kafka-based event sourcing
- **Field-Level Encryption** - AES-256-GCM for PII protection
- **Idempotency** - Redis-backed idempotency for all financial operations
- **Observability** - OpenTelemetry, Jaeger, Prometheus, Grafana integration

## Technology Stack

| Component | Version |
|-----------|---------|
| Java | 21 (Virtual Threads) |
| Spring Boot | 3.4.2 |
| Gradle | 8.5 (Kotlin DSL) |
| PostgreSQL | 16+ |
| Kafka | 3.x |
| Redis | 7.x |
| OpenTelemetry | 1.33.0 |

## Project Structure

```
xledger/
├── gradle/
│   └── libs.versions.toml         # Version Catalog (centralized dependency versions)
├── libs/                           # Foundation libraries
│   ├── common/                     # Common utilities, exceptions, DTOs
│   ├── domain/                     # Shared domain models
│   └── infra/                      # Infrastructure (crypto, observability)
├── services/                       # Business services (added per phase)
│   ├── ledger-service/            # (Phase 1) Core ledger
│   ├── account-service/           # (Phase 2) Account management
│   ├── cash-service/              # (Phase 2) Cash operations
│   └── admin-service/             # (Phase 3) Operations portal
├── docs/                          # Documentation
│   ├── prd.md                     # Product Requirements
│   ├── design.md                  # System Design
│   ├── requirements.md            # EARS Requirements
│   └── tasks.md                   # Task Breakdown
├── build.gradle.kts               # Root build configuration
├── settings.gradle.kts            # Multi-module settings
└── gradlew / gradlew.bat          # Gradle wrapper scripts
```

## Module Structure

### Foundation Modules (libs/) - ✅ Implemented

- **common** - Shared exceptions, API response formats, utilities
  - Dependencies: SLF4J, Jackson
  - Package: `com.xledger.common`
- **domain** - Domain value objects, event base classes
  - Dependencies: None (pure domain logic)
  - Package: `com.xledger.domain`
- **infra** - Encryption, hashing, idempotency, observability
  - Dependencies: Spring Boot, OpenTelemetry, Bouncy Castle, Argon2, Redis
  - Package: `com.xledger.infra`

### Service Modules (services/) - 🚧 Planned

Service modules will be added progressively across project phases:

- **Phase 1**: `ledger-service` - Core ledger functionality
- **Phase 2**: `account-service`, `cash-service` - Account & cash management
- **Phase 3**: `admin-service` - Operations and administration

## Dependency Management

This project uses **Gradle Version Catalog** (`gradle/libs.versions.toml`) for centralized dependency version management:

- All library versions are defined in one place
- Modules reference dependencies using `libs.xxx.xxx` notation
- Ensures version consistency across all modules
- Type-safe dependency declarations with IDE autocomplete

**Example usage in build.gradle.kts:**
```kotlin
dependencies {
    implementation(libs.slf4j.api)
    implementation(libs.jackson.databind)
}
```

## Getting Started

### Prerequisites

- Java 21 (via SDK manager or direct installation)
- Docker & Docker Compose (for local infrastructure)
- VS Code with DevContainer (recommended) or JetBrains Gateway

### Build

```bash
# Build all modules
./gradlew build

# Build specific module
./gradlew :libs:common:build

# Run tests
./gradlew test

# List all projects
./gradlew projects
```

### Development Environment

This project uses DevContainer for consistent development environments:

```bash
# Open in VS Code DevContainer
code .

# Or use JetBrains Gateway for remote development
```

## Development Workflow

### Branch Strategy

GitHub Flow is used for simplicity:

- `main` - Production-ready code
- `feature/{task-id}-{description}` - Feature branches
- `fix/{task-id}-{description}` - Bug fixes
- `docs/{description}` - Documentation updates

### Commit Convention

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

**Example**:
```
feat(ledger): implement journal entry creation

Add JournalEntry aggregate with debit/credit validation
Implement INSERT-ONLY persistence with triggers

Closes #1
```

### Merge Strategy

- Squash Merge to `main`
- Delete feature branches after merge
- PR required for all merges

## Phases

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| **Phase 0** | 2 weeks | Project structure, DevContainer, common libraries |
| **Phase 1** | 3 weeks | ledger-service MVP |
| **Phase 2** | 4 weeks | account-service, cash-service |
| **Phase 3** | TBD | admin-service, AML, archiving |

## Documentation

- [PRD (Product Requirements)](docs/prd.md)
- [Design Document](docs/design.md)
- [Requirements (EARS)](docs/requirements.md)
- [Task Breakdown](docs/tasks.md)

## License

This is a portfolio project for educational and demonstration purposes.

## Contact

**Project**: Xledger  
**Owner**: dongwonkwak  
**Repository**: https://github.com/dongwonkwak/xledger
