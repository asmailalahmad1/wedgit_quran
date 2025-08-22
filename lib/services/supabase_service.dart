// lib/services/supabase_service.dart

import 'package:ayah_wa_taamul/models/verse_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// الحصول على نسخة من عميل Supabase
final supabase = Supabase.instance.client;

class SupabaseService {
  // دالة لجلب آية عشوائية من قاعدة البيانات
  Future<Verse> getRandomVerse() async {
    try {
      // استدعاء دالة RPC التي أنشأناها في لوحة تحكم Supabase
      final response = await supabase.rpc('get_random_verse');

      // الدالة ترجع كائن JSON واحد مباشرة، لذا نقوم بتحويله
      return Verse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('حدث خطأ أثناء جلب آية عشوائية: $e');

      // في حالة حدوث خطأ، قم بإرجاع آية افتراضية لتجنب تعطل التطبيق
      return Verse(
        id: 0,
        surahName: 'خطأ',
        verseNumber: 0,
        verseText: 'حدث خطأ أثناء جلب الآية',
        tafsir: 'يرجى التحقق من اتصالك بالإنترنت وإعدادات Supabase.',
        benefits: '',
      );
    }
  }
}
