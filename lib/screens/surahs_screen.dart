// lib/screens/surahs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quran_provider.dart';
import 'reader_screen.dart';
import '../providers/bookmark_provider.dart';

class SurahsScreen extends ConsumerWidget {
  const SurahsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);
    final bookmark = ref.watch(bookmarkProvider);

    return Scaffold(
      // ✅ AppBar يأخذ تصميمه تلقائيًا
      appBar: AppBar(
        title: const Text('فهرس السور'),
      ),
      // ✅ الزر العائم يأخذ تصميمه (اللون والخط) من الثيم
      floatingActionButton: bookmark != null
          ? FloatingActionButton.extended(
              onPressed: () {
                final surahsData = ref.read(surahsProvider);
                surahsData.whenData((surahs) {
                  if (surahs.isNotEmpty) {
                    final bookmarkedSurah = surahs.firstWhere(
                      (s) => s['id'] == bookmark.surahId,
                      orElse: () => {},
                    );
                    if (bookmarkedSurah.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(
                            surahId: bookmark.surahId,
                            surahName: bookmarkedSurah['name_arabic'],
                          ),
                        ),
                      );
                    }
                  }
                });
              },
              label: const Text('العودة إلى الموضع المحفوظ'),
              icon: const Icon(Icons.bookmark_rounded),
            )
          : null,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: surahsAsync.when(
          data: (surahs) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              final isBookmarked =
                  bookmark != null && bookmark.surahId == surah['id'];

              // ✅ --- استخدام بطاقة (Card) لكل سورة لتصميم متناسق ---
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // ✅ تصميم موحد لعرض رقم السورة أو أيقونة العلامة
                  leading: SizedBox(
                    width: 40,
                    child: Center(
                      child: isBookmarked
                          ? Icon(
                              Icons.bookmark_rounded,
                              // ✅ استخدام لون التمييز الذهبي للعلامة
                              color: Theme.of(context).colorScheme.secondary,
                              size: 28,
                            )
                          : Text(
                              surah['id'].toString(),
                              // ✅ استخدام نمط متناسق لرقم السورة
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6)),
                            ),
                    ),
                  ),
                  // ✅ العنوان يستخدم النمط من الثيم مباشرة (خط Alegreya)
                  title: Text(
                    surah['name_arabic'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  // ✅ النص الفرعي يستخدم النمط من الثيم مباشرة
                  subtitle: Text(
                    'عدد آياتها: ${surah['verses_count']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReaderScreen(
                          surahId: surah['id'],
                          surahName: surah['name_arabic'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('خطأ: $err')),
        ),
      ),
    );
  }
}
