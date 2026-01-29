plugins {
    alias(libs.plugins.spring.boot) apply false
    alias(libs.plugins.spring.dependency.management) apply false
    alias(libs.plugins.spotless) apply false
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
    apply(plugin = "checkstyle")
    apply(plugin = "com.diffplug.spotless")

    val libs = rootProject.libs

    // Java 버전 설정
    configure<JavaPluginExtension> {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(libs.versions.javaVersion.get().toInt()))
        }
    }

    // Checkstyle 설정
    configure<CheckstyleExtension> {
        toolVersion = libs.versions.checkstyle.get()
        configFile = rootProject.file("config/checkstyle/checkstyle.xml")
        configDirectory.set(rootProject.file("config/checkstyle"))
        isIgnoreFailures = false
        maxWarnings = 0
    }

    // Spotless 설정
    configure<com.diffplug.gradle.spotless.SpotlessExtension> {
        java {
            target("src/**/*.java")
            googleJavaFormat(libs.versions.googleJavaFormat.get())
            removeUnusedImports()
            trimTrailingWhitespace()
            endWithNewline()
        }
    }

    tasks.withType<JavaCompile> {
        options.encoding = "UTF-8"
        options.compilerArgs.addAll(listOf("-parameters"))
    }

    tasks.withType<Test> {
        useJUnitPlatform()
    }

    // build task가 code quality checks를 포함하도록 설정
    tasks.named("check") {
        dependsOn("checkstyleMain", "checkstyleTest", "spotlessCheck")
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
