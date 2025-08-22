// lib/widgets/ayah_share_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verse_model.dart';

class AyahShareCard extends StatelessWidget {
  final Verse verse;

  const AyahShareCard({super.key, required this.verse});

  // ✅ --- تعريف الألوان والأنماط لتتوافق مع هوية التطبيق ---
  static const Color primaryIndigo = Color(0xFF2E6560);
  static const Color accentGold = Color(0xFFB8860B);
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFE0E0E0); // رمادي فاتح جدًا

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: const MediaQueryData(),
      child: Material(
        child: Container(
          width: 450,
          height: 800,
          // ✅ --- استخدام خلفية متدرجة بدلاً من اللون الصلب ---
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryIndigo, // يبدأ بالنيلي الداكن في الأعلى
                Color.lerp(primaryIndigo, accentGold,
                    0.5)!, // يمتزج مع الذهبي في المنتصف
                Color.lerp(primaryIndigo, accentGold,
                    0.7)!, // يصبح أقرب للذهبي في الأسفل
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.6, 1.0], // نقاط توقف التدرج للتحكم في المزج
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ عنوان "آية وتأمل" الآن باللون الأبيض ليكون أوضح على التدرج
                  Text(
                    'آية وتأمل',
                    style: GoogleFonts.alegreya(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      shadows: [
                        // إضافة ظل خفيف جدًا لزيادة الوضوح
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1.0, 1.0),
                        ),
                      ],
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Spacer(flex: 2),

                  // نص الآية
                  Text(
                    '"${verse.verseText}"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alegreya(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1.9,
                      color: primaryTextColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // اسم السورة
                  Text(
                    '${verse.surahName} - آية ${verse.verseNumber}',
                    style: GoogleFonts.alegreya(
                      fontSize: 18,
                      color: secondaryTextColor,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 24.0, horizontal: 80.0),
                    child: Divider(color: accentGold, thickness: 0.5),
                  ),

                  // قسم التفسير
                  _buildSection(
                    title: 'التفسير الميسر:',
                    content: verse.tafsir ?? 'لا يتوفر تفسير لهذه الآية.',
                  ),
                  const Spacer(flex: 1),

                  // قسم الفوائد
                  _buildSection(
                    title: 'تأملات وفوائد:',
                    content: verse.benefits ?? 'لا توجد فوائد متاحة.',
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.alegreya(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: accentGold, // اللون الذهبي للعناوين يبقى مميزًا
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.alegreya(
            fontSize: 17,
            height: 1.7,
            color: secondaryTextColor,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
