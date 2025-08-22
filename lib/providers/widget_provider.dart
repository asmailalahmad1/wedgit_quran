// lib/providers/widget_provider.dart
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/verse_model.dart';

// اسم الويدجت كما هو معرف في كود أندرويد
const String androidWidgetName = 'AyahWidgetProvider';

// هذه هي الدالة التي يتم استدعاؤها في الخلفية لتحديث الويدجت
@pragma("vm:entry-point")
Future<void> updateWidget(Uri? uri) async {
  try {
    if (kDebugMode) {
      print("-> تحديث الويدجت...");
    }

    final supabase = Supabase.instance.client;

    // جلب آية عشوائية باستخدام .single() مباشرة
    // لا حاجة للتحقق من null لأن .single() ستطلق خطأ إذا لم تجد بيانات
    final response = await supabase.rpc('get_random_verse').single();

    // تحويل البيانات من Map إلى كائن Verse
    // لا حاجة للتحويل 'as Map' لأن المترجم يعرف النوع
    final verse = Verse.fromJson(response);

    // حفظ البيانات التي ستقرأها الويدجت في كود Kotlin
    await Future.wait([
      HomeWidget.saveWidgetData<int>('verse_id', verse.id),
      HomeWidget.saveWidgetData<String>('verse_text', verse.verseText),
      HomeWidget.saveWidgetData<String>(
        'verse_ref',
        '${verse.surahName} - آية ${verse.verseNumber}',
      ),
    ]);

    // إرسال إشارة إلى نظام أندرويد لتحديث واجهة الويدجت
    await HomeWidget.updateWidget(name: androidWidgetName);

    if (kDebugMode) {
      print("-> تم تحديث الويدجت بنجاح بالآية ID: ${verse.id}");
    }
  } catch (e) {
    if (kDebugMode) {
      // طباعة أي خطأ يحدث أثناء العملية
      print('-> ❌ حدث خطأ أثناء تحديث الويدجت: $e');
    }
  }
}
