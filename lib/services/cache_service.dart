// lib/services/cache_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verse_model.dart';

class CacheService {
  static const _cacheKey = 'verses_cache';
  static const _cacheSize = 20; // عدد الآيات التي سنخزنها

  // جلب قائمة جديدة من الآيات من Supabase وتخزينها
  static Future<void> refreshCache() async {
    try {
      print("-> [Cache] تحديث ذاكرة التخزين المؤقت...");
      final supabase = Supabase.instance.client;
      final response = await supabase
          .rpc('get_random_verses', params: {'limit_count': _cacheSize});

      if (response != null && (response as List).isNotEmpty) {
        final List<Verse> verses =
            response.map((item) => Verse.fromJson(item)).toList();
        // تحويل قائمة الآيات إلى قائمة من النصوص (JSON strings)
        final List<String> versesJson =
            verses.map((verse) => jsonEncode(verse.toJson())).toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_cacheKey, versesJson);
        print("-> [Cache] تم تخزين ${_cacheSize} آية جديدة بنجاح.");
      }
    } catch (e) {
      print("-> [Cache] ❌ فشل في تحديث ذاكرة التخزين المؤقت: $e");
    }
  }

  // جلب آية عشوائية من الذاكرة المحلية
  static Future<Verse?> getVerseFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? versesJson = prefs.getStringList(_cacheKey);

      if (versesJson != null && versesJson.isNotEmpty) {
        // اختيار آية عشوائية من القائمة المخزنة
        final randomVerseJson = versesJson[Random().nextInt(versesJson.length)];
        final verse = Verse.fromJson(jsonDecode(randomVerseJson));
        print(
            "-> [Cache] تم جلب آية من الذاكرة المؤقتة: ${verse.surahName} - ${verse.verseNumber}");
        return verse;
      }
      return null;
    } catch (e) {
      print("-> [Cache] ❌ فشل في جلب آية من الذاكرة المؤقتة: $e");
      return null;
    }
  }
}
