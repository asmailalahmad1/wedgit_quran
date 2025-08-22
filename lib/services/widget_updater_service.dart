// // lib/providers/widget_provider.dart
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:home_widget/home_widget.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/verse_model.dart';

// // هذا هو اسم المجموعة للم виджет (مطلوب لـ iOS، يمكن تجاهله لأندرويد)
// const String appGroupId = 'YOUR_APP_GROUP_ID';
// const String androidWidgetName = 'AyahWidgetProvider';

// // هذه الدالة تعمل في الخلفية
// @pragma("vm:entry-point")
// Future<void> updateWidget() async {
//   if (kDebugMode) {
//     print("----- بدء تحديث الويدجت في الخلفية... -----");
//   }

//   try {
//     // --- الإضافة الحاسمة هنا ---
//     // يجب تهيئة Supabase داخل هذه الدالة لأنها تعمل في معزل (isolate)
//     await Supabase.initialize(
//       url: 'https://ilzttizoyuqdsacapybs.supabase.co', // <-- الرابط الخاص بك
//       anonKey:
//           'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlsenR0aXpveXVxZHNhY2FweWJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4MTQzNjgsImV4cCI6MjA3MDM5MDM2OH0.5uPtYJdFRci5LiE1LftYk3STn3jdTVbLw5UxoV8MfWY', // <-- المفتاح الخاص بك
//     );
//     // ----------------------------

//     final supabase = Supabase.instance.client;
//     final response = await supabase.rpc('get_random_verse');

//     if (response != null && (response as List).isNotEmpty) {
//       final verseData = response[0];
//       final verse = Verse.fromJson(verseData);

//       // حفظ البيانات للويدجت
//       await Future.wait([
//         HomeWidget.saveWidgetData<int>('verse_id', verse.id),
//         HomeWidget.saveWidgetData<String>('verse_text', verse.verseText),
//         HomeWidget.saveWidgetData<String>(
//           'verse_ref',
//           '${verse.surahName} - آية ${verse.verseNumber}',
//         ),
//       ]);

//       // تحديث الويدجت
//       await HomeWidget.updateWidget(name: androidWidgetName);
//       if (kDebugMode) {
//         print("✅ تم تحديث الويدجت بنجاح بالآية ID: ${verse.id}");
//       }
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print('❌ حدث خطأ أثناء تحديث الويدجت: $e');
//     }
//   }
// }
// lib/services/widget_updater_service.dart
import 'package:ayah_wa_taamul/providers/widget_provider.dart';
import 'package:workmanager/workmanager.dart';

// هذا هو اسم المهمة الفريد الذي سنستخدمه
const widgetUpdateTask = "updateAyahWidgetTask";

// @pragma('vm:entry-point') مهمة جدًا لتعمل في الخلفية
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == widgetUpdateTask) {
      // عندما يحين وقت المهمة، قم باستدعاء دالة تحديث الويدجت التي أنشأناها بالفعل
      print("Workmanager: بدء تحديث الويدجت الدوري...");
      try {
        await updateWidget(null);
        print("Workmanager: اكتمل تحديث الويدجت بنجاح.");
        return Future.value(true);
      } catch (e) {
        print("Workmanager: حدث خطأ أثناء التحديث: $e");
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}
