plugins {
    alias(libs.plugins.spring.boot) apply false
    alias(libs.plugins.spring.dependency.management) apply false
}

allprojects {
    group = "com.xledger"
    version = "0.1.0-SNAPSHOT"

    repositories {
        mavenCentral()
    }
}

subprojects {
    apply(plugin = "java")
    apply(plugin = "java-library")
    apply(plugin = "io.spring.dependency-management")

    val libs = rootProject.libs

    // Java 버전 설정
    configure<JavaPluginExtension> {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(libs.versions.javaVersion.get().toInt()))
        }
    }

    tasks.withType<JavaCompile> {
        options.encoding = "UTF-8"
        options.compilerArgs.addAll(listOf("-parameters"))
    }

    tasks.withType<Test> {
        useJUnitPlatform()
    }

    dependencies {
        val testImplementation by configurations
        val testRuntimeOnly by configurations

        // JUnit 5 - Note: subprojects can override with version catalog
        testImplementation(libs.junit.jupiter.api)
        testRuntimeOnly(libs.junit.jupiter.engine)
        testImplementation(libs.assertj.core)
    }
}
