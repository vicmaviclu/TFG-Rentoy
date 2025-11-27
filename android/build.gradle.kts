allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define default SDK versions as extra properties so plugin modules
// (for example android libraries inside Flutter plugins) can read them
// during their configuration. Some plugin build scripts expect these
// to be present when using the Kotlin DSL root build file.
extra["compileSdkVersion"] = 33
extra["targetSdkVersion"] = 33
extra["minSdkVersion"] = 21

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
