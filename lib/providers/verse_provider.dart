// lib/providers/verse_provider.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verse_model.dart';
import '../main.dart';
import 'connectivity_provider.dart';
import '../services/cache_service.dart';

final verseProvider = FutureProvider.autoDispose<Verse>((ref) async {
  // نراقب حالة الاتصال
  final connectivityResult = await ref.watch(connectivityProvider.future);
  final isConnected = connectivityResult != ConnectivityResult.none;

  final initialId = ref.watch(initialVerseIdProvider);
  final supabase = Supabase.instance.client;

  // --- المنطق المبسط ---

  // الحالة 1: جلب آية محددة من الويدجت (هذه لها الأولوية القصوى)
  if (initialId != null && initialId != -1) {
    Future.microtask(
        () => ref.read(initialVerseIdProvider.notifier).state = null);
    try {
      // حاول جلبها من الإنترنت إذا كان متصلاً
      if (isConnected) {
        final response =
            await supabase.from('verses').select().eq('id', initialId).single();
        return Verse.fromJson(response);
      }
    } catch (e) {
      // إذا فشل (حتى مع وجود نت)، لا تفعل شيئًا، دع الكود يستمر ليجلب من الكاش أو آية عشوائية
      print("Failed to fetch specific verse by ID, falling back. Error: $e");
    }
  }

  // الحالة 2: هناك اتصال بالإنترنت، اجلب آية عشوائية وحدث الكاش
  if (isConnected) {
    // تحديث الكاش في الخلفية
    CacheService.refreshCache();
    try {
      final response = await supabase.rpc('get_random_verse').single();
      return Verse.fromJson(response);
    } catch (e) {
      // إذا فشل الاتصال بالخادم، الجأ إلى الكاش
      print("Failed to fetch random verse from API, trying cache. Error: $e");
      final cachedVerse = await CacheService.getVerseFromCache();
      if (cachedVerse != null) return cachedVerse;
      throw Exception('فشل في جلب الآية. يرجى المحاولة مرة أخرى.');
    }
  }
  // الحالة 3: لا يوجد اتصال بالإنترنت، اذهب مباشرة إلى الكاش
  else {
    final cachedVerse = await CacheService.getVerseFromCache();
    if (cachedVerse != null) {
      return cachedVerse;
    } else {
      throw Exception(
          'لا يوجد اتصال بالإنترنت، ولم يتم العثور على بيانات مخزنة.');
    }
  }
});
