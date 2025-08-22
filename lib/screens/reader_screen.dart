// lib/screens/reader_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/quran_provider.dart';
import '../providers/bookmark_provider.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final int surahId;
  final String surahName;

  const ReaderScreen({
    super.key,
    required this.surahId,
    required this.surahName,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int _firstVisibleItemIndex = 0;
  bool _isInitialJumpDone = false;

  @override
  void initState() {
    super.initState();
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty && mounted) {
        setState(() {
          _firstVisibleItemIndex = positions.first.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(versesBySurahProvider(widget.surahId));

    return Scaffold(
      // ✅ AppBar يأخذ تصميمه تلقائيًا من الثيم (خط Alegreya ولون صحيح)
      appBar: AppBar(
        title: Text(widget.surahName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'حفظ الموضع الحالي',
            onPressed: () {
              ref
                  .read(bookmarkProvider.notifier)
                  .saveBookmark(widget.surahId, _firstVisibleItemIndex);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ الموضع بنجاح'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: versesAsync.when(
        data: (verses) {
          final bookmark = ref.watch(bookmarkProvider);
          if (!_isInitialJumpDone &&
              bookmark != null &&
              bookmark.surahId == widget.surahId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (itemScrollController.isAttached) {
                itemScrollController.scrollTo(
                  index: bookmark.verseIndex,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                );
                if (mounted) {
                  setState(() {
                    _isInitialJumpDone = true;
                  });
                }
              }
            });
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            // ✅ استخدام ScrollablePositionedList لعرض الآيات
            child: ScrollablePositionedList.builder(
              itemCount: verses.length,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemBuilder: (context, index) {
                final verse = verses[index];
                // ✅ --- بطاقة الآية المعاد تصميمها لتتوافق مع هوية التطبيق ---
                return Card(
                  elevation: 0, // ظل خفيف أو بدون ظل
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ رقم الآية داخل دائرة مزخرفة بلون التمييز الذهبي
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                          child: Text(
                            verse.verseNumber.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alegreya',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ✅ نص الآية يستخدم النمط من الثيم مباشرةً
                        Expanded(
                          child: Text(
                            verse.verseText,
                            // ✅ استخدام النمط `headlineMedium` من الثيم لضمان الاتساق
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontSize:
                                      22, // يمكن تعديل الحجم قليلاً هنا إذا لزم الأمر
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        // ✅ المؤشر والخطأ يستخدمان تصميم الثيم الافتراضي
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}
