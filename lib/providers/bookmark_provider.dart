// lib/providers/bookmark_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// يمثل الموضع المحفوظ (سورة + آية)
class Bookmark {
  final int surahId;
  final int verseIndex; // سنحفظ index الآية (0, 1, 2...)

  Bookmark({required this.surahId, required this.verseIndex});
}

// Provider لإدارة حالة الموضع المحفوظ
final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, Bookmark?>((ref) {
  return BookmarkNotifier();
});

class BookmarkNotifier extends StateNotifier<Bookmark?> {
  BookmarkNotifier() : super(null) {
    _loadBookmark();
  }

  static const _surahKey = 'bookmark_surah_id';
  static const _verseKey = 'bookmark_verse_index';

  // تحميل الموضع المحفوظ من الذاكرة
  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final surahId = prefs.getInt(_surahKey);
    final verseIndex = prefs.getInt(_verseKey);
    if (surahId != null && verseIndex != null) {
      state = Bookmark(surahId: surahId, verseIndex: verseIndex);
    }
  }

  // حفظ موضع جديد
  Future<void> saveBookmark(int surahId, int verseIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_surahKey, surahId);
    await prefs.setInt(_verseKey, verseIndex);
    state = Bookmark(surahId: surahId, verseIndex: verseIndex);
  }

  // حذف الموضع المحفوظ
  Future<void> clearBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_surahKey);
    await prefs.remove(_verseKey);
    state = null;
  }
}
