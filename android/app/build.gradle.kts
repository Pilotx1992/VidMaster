import java.util.Base64
import java.util.Properties

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

val releaseSigningPropsFile = listOf(
    rootProject.file("key.properties"),
    file("key.properties")
).firstOrNull { it.exists() }

val releaseSigningProps = Properties().apply {
    releaseSigningPropsFile?.inputStream()?.use { load(it) }
}

fun releaseSigningValue(key: String): String? =
    releaseSigningProps.getProperty(key)?.takeIf { it.isNotBlank() }

val hasReleaseSigningConfig = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword"
).all { releaseSigningValue(it) != null }

val isReleaseTask =
    gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }

if (isReleaseTask && !hasReleaseSigningConfig) {
    throw GradleException(
        "Release signing is not configured. Copy android/key.properties.example to android/key.properties " +
            "and set storeFile, storePassword, keyAlias, and keyPassword (never commit key.properties). " +
            "Refusing to sign release builds with debug keys."
    )
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
        applicationId = "com.vidmaster.app"
        minSdk = 26
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigningConfig) {
            create("release") {
                val storeFilePath = releaseSigningValue("storeFile")!!
                storeFile = rootProject.file(storeFilePath)
                storePassword = releaseSigningValue("storePassword")!!
                keyAlias = releaseSigningValue("keyAlias")!!
                keyPassword = releaseSigningValue("keyPassword")!!
            }
        }
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
            if (hasReleaseSigningConfig) {
                signingConfig = signingConfigs.getByName("release")
            }
            
            // Enable minification and resource shrinking for smaller builds
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

plugins.withId("com.chaquo.python") {
    // Only enabled on Experimental builds via isExperimentalBuild above.
    val pythonPath = (findProperty("vidmasterPython") as String?)
        ?.takeIf { it.isNotBlank() }
        ?: System.getenv("VIDMASTER_PYTHON")

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
