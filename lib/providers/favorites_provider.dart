// lib/providers/favorites_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verse_model.dart';

// Provider لإدارة قائمة IDs الآيات المفضلة
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<int>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<int>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  static const _favoritesKey = 'favorite_verses_ids';

  // تحميل قائمة IDs المفضلة من ذاكرة الهاتف
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIdsAsString = prefs.getStringList(_favoritesKey) ?? [];
    state = favoriteIdsAsString.map((id) => int.parse(id)).toList();
  }

  // إضافة أو إزالة آية من المفضلة
  Future<void> toggleFavorite(int verseId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFavorites = List<int>.from(state);

    if (currentFavorites.contains(verseId)) {
      currentFavorites.remove(verseId);
    } else {
      currentFavorites.add(verseId);
    }

    // حفظ القائمة المحدثة في ذاكرة الهاتف
    final favoriteIdsAsString =
        currentFavorites.map((id) => id.toString()).toList();
    await prefs.setStringList(_favoritesKey, favoriteIdsAsString);

    state = currentFavorites; // تحديث الحالة لإعلام الواجهة
  }
}

// Provider لجلب تفاصيل الآيات المفضلة من Supabase
final favoriteVersesProvider =
    FutureProvider.autoDispose<List<Verse>>((ref) async {
  final favoriteIds = ref.watch(favoritesProvider);

  if (favoriteIds.isEmpty) {
    return []; // إرجاع قائمة فارغة إذا لم يكن هناك مفضلات
  }

  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('verses').select().inFilter('id', favoriteIds);
  return response.map((item) => Verse.fromJson(item)).toList();
});
