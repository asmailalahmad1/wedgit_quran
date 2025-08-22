// lib/screens/home_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:ayah_wa_taamul/screens/surahs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../models/verse_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/verse_provider.dart';
import '../providers/widget_provider.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/ayah_share_card.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVerse = ref.watch(verseProvider);

    // سيتم تطبيق لون الخلفية تلقائيًا من الثيم (lightTheme/darkTheme)
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: asyncVerse.when(
                    data: (verse) => _buildVerseContent(context, verse, ref,
                        key: ValueKey('verse_${verse.id}')),
                    loading: () => Center(
                        key: const ValueKey('loading'),
                        child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary)),
                    error: (err, stack) => _buildErrorContent(
                        context, err.toString(), ref,
                        key: const ValueKey('error')),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _captureAndShare(BuildContext context, Verse verse) async {
    messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('جاري تحضير الصورة للمشاركة...')));
    try {
      final imageBytes = await _screenshotController.captureFromWidget(
        AyahShareCard(verse: verse),
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
        delay: const Duration(milliseconds: 100),
      );
      messengerKey.currentState?.hideCurrentSnackBar();
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/shared_ayah.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);
      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            'آية وتأمل ✨\n\n"${verse.verseText}"\n(${verse.surahName} - آية ${verse.verseNumber})\n\n#آية_وتأمل',
      );
    } catch (e) {
      messengerKey.currentState?.hideCurrentSnackBar();
      messengerKey.currentState
          ?.showSnackBar(SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')));
    }
  }

  // ✅ --- تم تعديل هذه الدالة بالكامل لتعتمد على الثيم الذي قدمته ---
  Widget _buildVerseContent(BuildContext context, Verse verse, WidgetRef ref,
      {Key? key}) {
    // تحديد لون خلفية الحاوية الضبابية بناءً على الثيم
    final containerColor =
        Theme.of(context).colorScheme.surface.withOpacity(0.65);
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.1);

    return RefreshIndicator(
      key: key,
      onRefresh: () => ref.refresh(verseProvider.future),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          _buildTopBar(context, ref),
          const SizedBox(height: 10),

          // --- حاوية الآية (تستخدم الثيم) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  verse.verseText,
                  textAlign: TextAlign.center,
                  // استخدام نمط الخط headlineMedium من الثيم مباشرة
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- اسم السورة (يستخدم الثيم) ---
          Text(
            '${verse.surahName} - آية ${verse.verseNumber}',
            textAlign: TextAlign.center,
            // استخدام نمط الخط bodySmall من الثيم
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Divider(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              indent: 40,
              endIndent: 40),
          const SizedBox(height: 24),

          // --- حاوية التفسير والفوائد (تستخدم الثيم) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'التفسير الميسر:'),
                    const SizedBox(height: 8),
                    Text(
                      verse.tafsir ?? 'لا يوجد تفسير متاح.',
                      // استخدام نمط الخط bodyMedium من الثيم
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'تأملات وفوائد:'),
                    const SizedBox(height: 8),
                    Text(
                      verse.benefits ?? 'لا توجد فوائد متاحة.',
                      // استخدام نمط الخط bodyMedium من الثيم
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          _buildActionButtons(context, verse, ref),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ --- تم تبسيطها لتعتمد على الثيم ---
  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
    // ✅ جلب اللون الأساسي مباشرة من الثيم
    final iconColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              // ✅ تطبيق اللون على الأيقونة
              icon: Icon(Icons.bookmark_border_rounded, color: iconColor),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoritesScreen())),
              tooltip: 'المفضلة',
            ),
            IconButton(
              // ✅ تطبيق اللون على الأيقونة
              icon: Icon(Icons.settings_outlined, color: iconColor),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen())),
              tooltip: 'الإعدادات',
            ),
          ],
        ),
        Text('آية وتأمل', style: Theme.of(context).appBarTheme.titleTextStyle),
        IconButton(
          // ✅ تطبيق اللون على الأيقونة
          icon: Icon(Icons.menu_book_rounded, color: iconColor),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SurahsScreen())),
          tooltip: 'فهرس السور',
        ),
      ],
    );
  }

  // ✅ --- تم تبسيطها لتعتمد على الثيم ---
  Widget _buildSectionTitle(BuildContext context, String title) {
    // استخدام نمط الخط titleLarge من الثيم
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  // ✅ --- تم تبسيطها لتعتمد على الثيم ---
  Widget _buildActionButtons(BuildContext context, Verse verse, WidgetRef ref) {
    final textToCopy =
        '"${verse.verseText}"\n(${verse.surahName} - آية ${verse.verseNumber})\n\nالتفسير الميسر:\n${verse.tafsir ?? "لا يوجد تفسير متاح."}';
    final favoriteIds = ref.watch(favoritesProvider);
    final isFavorite = favoriteIds.contains(verse.id);

    // ✅ جلب اللون الأساسي مباشرة من الثيم
    final iconColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            // أيقونة المفضلة لها حالة خاصة (أحمر عند التفعيل)
            color: isFavorite ? Colors.redAccent : iconColor,
            size: 28,
          ),
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggleFavorite(verse.id);
          },
          tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        ),
        IconButton(
          // ✅ تطبيق اللون على الأيقونة
          icon: Icon(Icons.copy_outlined, color: iconColor, size: 28),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: textToCopy));
            messengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text('تم نسخ الآية والتفسير!')));
          },
          tooltip: 'نسخ النص',
        ),
        IconButton(
          // ✅ تطبيق اللون على الأيقونة
          icon: Icon(Icons.image_outlined, color: iconColor, size: 28),
          onPressed: () => _captureAndShare(context, verse),
          tooltip: 'مشاركة كصورة',
        ),
        IconButton(
          // ✅ تطبيق اللون على الأيقونة
          icon: Icon(Icons.refresh_rounded, color: iconColor, size: 28),
          onPressed: () {
            ref.invalidate(verseProvider);
            updateWidget(null);
          },
          tooltip: 'تحديث الآية',
        ),
      ],
    );
  }

  // (بدون تغيير)
  Widget _buildErrorContent(BuildContext context, String error, WidgetRef ref,
      {Key? key}) {
    final bool isConnectionError = error.contains('لا يوجد اتصال بالإنترنت');
    return Padding(
      key: key,
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isConnectionError
                ? Icons.wifi_off_rounded
                : Icons.error_outline_rounded,
            color: isConnectionError ? Colors.orangeAccent : Colors.redAccent,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            isConnectionError ? 'خطأ في الاتصال' : 'حدث خطأ ما',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 28, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(verseProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
