rootProject.name = "xledger"

// Foundation modules
include("libs:common")
include("libs:domain")
include("libs:infra")

// Plugin management
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}

// Dependency resolution management
dependencyResolutionManagement {
    repositories {
        mavenCentral()
    }
}
