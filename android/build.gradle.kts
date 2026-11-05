allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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

subprojects {
    afterEvaluate {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val setter = android.javaClass.methods.find { it.name == "setCompileSdk" || it.name == "setCompileSdkVersion" }
                setter?.invoke(android, 36)
            } catch (e: Exception) {
                try {
                    val method = android.javaClass.methods.find { it.name == "compileSdkVersion" }
                    method?.invoke(android, 36)
                } catch (e2: Exception) {
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
