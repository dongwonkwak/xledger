plugins {
    `java-library`
}

description = "Common utilities, exceptions, and API response formats"

dependencies {
    // Logging
    implementation(libs.slf4j.api)
    
    // Jackson for JSON
    implementation(libs.jackson.databind)
    implementation(libs.jackson.datatype.jsr310)
}
