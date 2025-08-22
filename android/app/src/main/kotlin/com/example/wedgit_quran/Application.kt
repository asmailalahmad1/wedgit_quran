// package com.example.wedgit_quran

// import io.flutter.app.FlutterApplication
// import io.flutter.plugin.common.PluginRegistry
// import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
// import io.flutter.plugins.GeneratedPluginRegistrant
// import androidx.work.Configuration
// import android.util.Log

// class Application : FlutterApplication(), PluginRegistrantCallback, Configuration.Provider {
//     override fun onCreate() {
//         super.onCreate()
//     }

//     // تم تحديث هذا الجزء ليتوافق مع فلاتر الحديث
//     override fun registerPlugins(registry: PluginRegistry?) {
//         if (registry != null) {
//             GeneratedPluginRegistrant.registerWith(registry)
//         }
//     }

//     // تم تحديث هذا الجزء ليتوافق مع فلاتر الحديث
//     override fun getWorkManagerConfiguration(): Configuration {
//         // يمكنك استخدام Builder() إذا كنت تحتاج إلى إعدادات مخصصة
//         return Configuration.Builder()
//             .setMinimumLoggingLevel(Log.DEBUG) // استخدم Log.INFO في نسخة الإصدار
//             .build()
//     }
// }