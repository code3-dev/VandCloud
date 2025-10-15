allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Removed custom build directory redirection which can cause file locking issues

subprojects {
    // Removed problematic build directory evaluation
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}