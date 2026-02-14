# ProGuard/R8 rules for Pregame World Cup 2026
# For details: https://developer.android.com/guide/developing/tools/proguard.html

# ==================== DEBUGGING ====================

# Preserve line numbers for Firebase Crashlytics stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ==================== FLUTTER ====================

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# ==================== FIREBASE ====================

-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services (auth, maps, ads, etc.)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ==================== STRIPE ====================

-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# ==================== GOOGLE MAPS ====================

-keep class com.google.android.libraries.maps.** { *; }
-keep class com.google.maps.** { *; }

# ==================== GOOGLE MOBILE ADS (AdMob) ====================

-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# ==================== REVENUECAT ====================

-keep class com.revenuecat.purchases.** { *; }
-dontwarn com.revenuecat.purchases.**

# ==================== GSON (used internally by Firebase/Stripe) ====================

-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ==================== OKHTTP (used by Stripe/networking) ====================

-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ==================== GENERAL ====================

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
} 