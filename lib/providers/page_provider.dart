// Provider لجلب كل آيات صفحة معينة
import 'package:ayah_wa_taamul/models/verse_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final versesByPageProvider = FutureProvider.family
    .autoDispose<List<Verse>, int>((ref, pageNumber) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('verses')
      .select()
      .eq('page_number', pageNumber)
      .order('id', ascending: true); // الترتيب مهم جدًا

  return response.map((item) => Verse.fromJson(item)).toList();
});
