package com.xledger.infra;

/**
 * Marker class for infra module.
 * This package will contain infrastructure concerns such as:
 * - Encryption utilities (AES-256-GCM)
 * - Hashing utilities (SHA-256, Argon2)
 * - Idempotency handling
 * - OpenTelemetry integration
 * - Structured logging
 */
public final class InfraModule {
    private InfraModule() {
        // Prevent instantiation
    }
}
