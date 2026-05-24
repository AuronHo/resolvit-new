# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# OkHttp / HTTP
-dontwarn okhttp3.**
-dontwarn okio.**

# Play Core (Flutter deferred components — not used, suppress R8 errors)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
