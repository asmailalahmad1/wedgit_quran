// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verse_model.dart';
import '../main.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteVersesProvider);

    return Scaffold(
      // ✅ AppBar يأخذ تصميمه تلقائيًا من الثيم
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: favoritesAsync.when(
          data: (verses) {
            if (verses.isEmpty) {
              // ✅ استخدام دالة مساعدة لعرض شاشة "القائمة فارغة" بتصميم متناسق
              return _buildEmptyState(context);
            }
            // ✅ استخدام ListView.builder مع بطاقات مصممة حسب الثيم
            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final verse = verses[index];
                return Dismissible(
                  key: ValueKey(verse.id),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(verse.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تمت الإزالة من المفضلة'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'تراجع',
                          onPressed: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(verse.id);
                          },
                        ),
                      ),
                    );
                  },
                  // ✅ تحسين خلفية الحذف لتستخدم ألوان الثيم
                  background: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(
                      Icons.delete_sweep_rounded,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  child: _buildFavoriteVerseCard(context, ref, verse),
                );
              },
            );
          },
          // ✅ المؤشر يأخذ لونه من الثيم
          loading: () => const Center(child: CircularProgressIndicator()),
          // ✅ استخدام دالة مساعدة لعرض رسالة خطأ بتصميم أفضل
          error: (err, stack) => _buildErrorState(context, err),
        ),
      ),
    );
  }

  // ✅ --- دالة مساعدة لعرض حالة "القائمة فارغة" ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            // ✅ استخدام لون ثانوي من الثيم ليكون أكثر هدوءًا
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          // ✅ النص يستخدم النمط مباشرة من الثيم
          Text(
            'قائمة المفضلة فارغة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          // ✅ النص يستخدم النمط مباشرة من الثيم دون تخصيص للألوان
          Text(
            'أضف آيات بالضغط على أيقونة القلب ❤️\nفي الشاشة الرئيسية',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // ✅ --- دالة مساعدة لعرض حالة الخطأ ---
  Widget _buildErrorState(BuildContext context, Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ ما',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'لا يمكن تحميل المفضلة حاليًا.\nيرجى المحاولة مرة أخرى لاحقًا.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // ✅ --- ودجت بطاقة الآية المفضلة (تم تبسيطها لتعتمد على الثيم) ---
  Widget _buildFavoriteVerseCard(
      BuildContext context, WidgetRef ref, Verse verse) {
    return Card(
      // ✅ الهوامش والشكل واللون تأتي من الثيم
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        // ✅ النص الرئيسي يستخدم نمطًا من الثيم مباشرةً
        title: Text(
          verse.verseText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          // ✅ النص الفرعي يستخدم نمطًا من الثيم مباشرةً
          child: Text(
            '${verse.surahName} - آية ${verse.verseNumber}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        // ✅ الأيقونة تأخذ لونها من الثيم
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          ref.read(initialVerseIdProvider.notifier).state = verse.id;
          Navigator.pop(context);
        },
      ),
    );
  }
}
