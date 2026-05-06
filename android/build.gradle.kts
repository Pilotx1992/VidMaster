buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://chaquo.com/maven") }
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.6.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        classpath("com.chaquo.python:gradle:15.0.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://chaquo.com/maven") }
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

                // Force Java 17 and SDK 34 for all modules
                try {
                    val compileOptions = androidExt.javaClass.getMethod("getCompileOptions").invoke(androidExt)
                    compileOptions.javaClass.getMethod("setSourceCompatibility", Object::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
                    compileOptions.javaClass.getMethod("setTargetCompatibility", Object::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
                    
                    // Try both setCompileSdkVersion (old) and setCompileSdk (new)
                    try {
                        androidExt.javaClass.getMethod("setCompileSdkVersion", Object::class.java).invoke(androidExt, 34)
                    } catch (e: Exception) {
                        androidExt.javaClass.getMethod("setCompileSdk", Integer::class.java).invoke(androidExt, 34)
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

subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.arthenica" && requested.name == "ffmpeg-kit-full-gpl") {
                useVersion("6.0")
            }
        }
    }
}
