import java.util.Base64

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val isExperimentalBuild =
    gradle.startParameter.taskNames.any { it.contains("Experimental", ignoreCase = true) }
val vidMasterChannel = if (isExperimentalBuild) "experimental" else "stable"
val vidMasterChannelDefine = Base64.getEncoder()
    .encodeToString("VIDMASTER_CHANNEL=$vidMasterChannel".toByteArray())
val existingDartDefines = findProperty("dart-defines")?.toString()
extra["dart-defines"] = if (existingDartDefines.isNullOrBlank()) {
    vidMasterChannelDefine
} else if (existingDartDefines.contains(vidMasterChannelDefine)) {
    existingDartDefines
} else {
    "$existingDartDefines,$vidMasterChannelDefine"
}

if (isExperimentalBuild) {
    apply(plugin = "com.chaquo.python")
}

android {
    namespace = "com.vidmaster.app"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vidmaster.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "channel"
    productFlavors {
        create("stable") {
            dimension = "channel"
            applicationIdSuffix = ".stable"
            versionNameSuffix = "-stable"
        }
        create("experimental") {
            dimension = "channel"
            applicationIdSuffix = ".exp"
            versionNameSuffix = "-exp"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Enable minification and resource shrinking for smaller builds
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

plugins.withId("com.chaquo.python") {
    // Only enabled on Experimental builds via isExperimentalBuild above.
    val pythonPath = System.getenv("VIDMASTER_PYTHON")

    android.defaultConfig.ndk {
        abiFilters += listOf("armeabi-v7a", "arm64-v8a")
    }

    extensions.configure<com.chaquo.python.ChaquopyExtension>("chaquopy") {
        defaultConfig {
            // Prefer the most compatible interpreter for Chaquopy.
            version = "3.8"

            if (!pythonPath.isNullOrBlank() && file(pythonPath).exists()) {
                buildPython(pythonPath)
            }

            pip {
                val wheelhouse = file("src/experimental/python/wheels")
                val hasWheelhouse = wheelhouse.exists() && (wheelhouse.listFiles()?.isNotEmpty() == true)

                if (hasWheelhouse) {
                    options("--no-index")
                    options("--find-links=${wheelhouse.absolutePath}")
                } else {
                    options("--default-timeout=120")
                    options("--retries=10")
                }

                install("yt-dlp==2024.8.6")
                install("certifi")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // Avoid R8 missing classes when building split APKs.
    implementation("com.google.android.play:core:1.10.3")
}

flutter {
    source = "../.."
}

afterEvaluate {
    // Flutter tooling expects APKs under <projectRoot>/build/app/outputs/flutter-apk.
    val projectRoot = rootProject.projectDir.parentFile
    val flutterExpectedOut = File(projectRoot, "build/app/outputs/flutter-apk")
    tasks.matching { it.name.startsWith("assemble") && (it.name.endsWith("Debug") || it.name.endsWith("Release")) }
        .configureEach {
            doLast {
                val fromDir = File(buildDir, "outputs/flutter-apk")
                if (!fromDir.exists()) return@doLast
                flutterExpectedOut.mkdirs()
                fromDir.listFiles { f -> f.isFile && f.extension.equals("apk", ignoreCase = true) }
                    ?.forEach { apk ->
                        apk.copyTo(File(flutterExpectedOut, apk.name), overwrite = true)
                    }
            }
        }
}
