// lib/providers/quran_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verse_model.dart';

// Provider لجلب قائمة السور
final surahsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('surahs').select().order('id', ascending: true);
  return response;
});

// Provider لجلب آيات سورة معينة
final versesBySurahProvider =
    FutureProvider.family.autoDispose<List<Verse>, int>((ref, surahId) async {
  final supabase = Supabase.instance.client;
  // سنحتاج إلى عمود `surah_id` في جدول `verses`
  final response = await supabase
      .from('verses')
      .select()
      .eq('surah_id', surahId)
      .order('verse_number', ascending: true);

  return response.map((item) => Verse.fromJson(item)).toList();
});
