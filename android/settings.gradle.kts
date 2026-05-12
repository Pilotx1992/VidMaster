pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://chaquo.com/maven") }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.6.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.chaquo.python") version "15.0.1" apply false
}

// Flutter enables per-ABI APKs when split-per-abi is true (cannot mix with ndk.abiFilters — Chaquopy uses those).
// Enable only for stable *Release* assemble: `flutter run --flavor stable` uses Debug and must stay a single APK.
// Experimental + Chaquopy: never set split-per-abi (conflicts with defaultConfig.ndk.abiFilters).
gradle.beforeProject {
    if (path != ":app") {
        return@beforeProject
    }
    val taskNames = gradle.startParameter.taskNames
    val isExperimentalTask = taskNames.any { it.contains("Experimental", ignoreCase = true) }
    val wantsStableReleaseAbiSplits = taskNames.any { task ->
        task.contains("Stable", ignoreCase = true) &&
            task.contains("Release", ignoreCase = true) &&
            task.contains("assemble", ignoreCase = true) &&
            !task.contains("Experimental", ignoreCase = true)
    }
    if (!isExperimentalTask && wantsStableReleaseAbiSplits) {
        extensions.extraProperties.set("split-per-abi", "true")
    }
}

include(":app")
