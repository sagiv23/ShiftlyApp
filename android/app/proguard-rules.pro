# Flutter Core
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Hive
-keepattributes *Annotation*
-keepclassmembers class * {
    @HiveField <fields>;
}
-keep class * extends HiveObject
-keep class * implements TypeAdapter
