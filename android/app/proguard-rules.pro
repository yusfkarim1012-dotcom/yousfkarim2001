# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# FFmpegKit specific rules to prevent obfuscation
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-keep class X.** { *; }
-dontwarn com.antonkarpenko.ffmpegkit.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
