# Flutter rules are inserted by the Flutter tool base.gradle.

# --- قواعد Supabase (احتفظ بها) ---
-keep class io.supabase.** { *; }
-keep class io.ktor.** { *; }
-keep class io.realtime.** { *; }

# --- قواعد flutter_local_notifications ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# --- ✅ (صحيح ونهائي) قواعد الحفاظ على الموارد ---
-keepclassmembers class **.R$* {
    public static <fields>;
}

# --- (قواعد عامة) ---
-dontwarn kotlin.coroutines.jvm.internal.DebugMetadata