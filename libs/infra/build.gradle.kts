plugins {
    `java-library`
}

description = "Infrastructure concerns: encryption, hashing, observability, logging"

dependencies {
    // Common utilities
    implementation(project(":libs:common"))
    
    // Spring Boot starters (for idempotency filter, observability)
    compileOnly(libs.spring.boot.starter)
    compileOnly(libs.spring.boot.starter.web)
    
    // OpenTelemetry
    implementation(libs.opentelemetry.api)
    implementation(libs.opentelemetry.sdk)
    
    // Bouncy Castle for encryption
    implementation(libs.bouncycastle.provider)
    
    // Argon2 for password hashing
    implementation(libs.argon2.jvm)
    
    // Redis (for idempotency)
    compileOnly(libs.spring.data.redis)
}
