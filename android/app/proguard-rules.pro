# Isar preserves
-keep class io.isar.** { *; }
-keep class * implements io.isar.IsarCollection { *; }
-keep class * implements io.isar.IsarLink { *; }
-keep class * implements io.isar.IsarLinks { *; }

# MediaKit preserves
-keep class com.alexmercerind.mediakit.** { *; }

# Audio Service preserves
-keep class com.ryanheise.audioservice.** { *; }

# Flutter Downloader preserves
-keep class vn.hunghd.flutterdownloader.** { *; }

# General Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
