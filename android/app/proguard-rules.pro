# Add project specific ProGuard rules here.
# You can control the set of applied configuration files:
# -N to disable a built-in file
# -S to completely override the built-in files
# By default, the flags in this file are appended to flags specified
# in /usr/local/google/buildbot/src/googleplex-android/mnc-supportlib-release/android/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces:
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name:
#-renamesourcefileattribute SourceFile

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.BuildConfig { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class androidx.lifecycle.**  { *; }

# Flutter plugins
-keep class io.flutter.plugins.**  { *; }

# Gson specific classes
-dontwarn com.google.gson.**
-keep class com.google.gson.** { *; }

# Http library
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**

# OkHttp library
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Okio library
-keep class okio.** { *; }
-dontwarn okio.**

# Image library
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# Shared preferences
-keep class android.support.** { *; }
-keep interface android.support.** { *; }

# AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters in Views so that animations can still work.
# See http://developer.android.com/reference/android/view/animation/Animation.html#setDuration(long)
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

# We want to keep methods in Activity that could be used in the XML attribute onClick
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}

# R8 full mode optimizations
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}