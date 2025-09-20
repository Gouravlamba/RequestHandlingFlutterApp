// Root-level build.gradle.kts for your Android project in Flutter

// Configure repositories for all projects
allprojects {
    repositories {
        google()          // Google's Maven repository for Android dependencies
        mavenCentral()    // Maven Central repository for general dependencies
    }
}

// Define a centralized build directory outside of the module folders
val centralizedBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")   // This path keeps all build outputs in a common folder two levels up
    .get()

// Override the default build directory for the root project
rootProject.layout.buildDirectory.value(centralizedBuildDir)

// Configure subprojects to use their own subfolder inside the centralized build directory
subprojects {
    val subprojectBuildDir: Directory = centralizedBuildDir.dir(project.name)
    project.layout.buildDirectory.value(subprojectBuildDir)

    // Ensure that the :app module is evaluated before other subprojects
    project.evaluationDependsOn(":app")
}

// Register a custom clean task that deletes the centralized build directory
tasks.register<Delete>("clean") {
    delete(centralizedBuildDir)
}
