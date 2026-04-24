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
    afterEvaluate {
        if (hasProperty("android")) {
            val androidExt = extensions.findByName("android")
            if (androidExt != null) {
                try {
                    val getNamespace = androidExt.javaClass.getMethod("getNamespace")
                    val currentNamespace = getNamespace.invoke(androidExt)
                    if (currentNamespace == null) {
                        val setNamespace = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                        val pkg = group.toString().takeIf { it.isNotEmpty() } ?: "com.example.${name.replace('-', '_')}"
                        setNamespace.invoke(androidExt, pkg)
                    }
                } catch (e: Exception) {
                    // Ignore
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

