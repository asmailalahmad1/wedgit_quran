// // lib/models/verse_model.dart
// import 'package:supabase_flutter/supabase_flutter.dart';

// class Verse {
//   final int id;
//   final String surahName;
//   final int verseNumber;
//   final String verseText;
//   final String? tafsir;
//   final String? benefits;

//   Verse({
//     required this.id,
//     required this.surahName,
//     required this.verseNumber,
//     required this.verseText,
//     this.tafsir,
//     this.benefits,
//   });

//   factory Verse.fromJson(Map<String, dynamic> json) {
//     return Verse(
//       id: json['id'],
//       surahName: json['surah_name'],
//       verseNumber: json['verse_number'],
//       verseText: json['verse_text'],
//       tafsir: json['tafsir_muyassar'],
//       benefits: json['benefits'],
//     );
//   }
// }

// final supabase = Supabase.instance.client;

// class SupabaseService {
//   Future<Verse> getRandomVerse() async {
//     try {
//       final response = await supabase.rpc('get_random_verse');
//       // The RPC returns a single JSON object directly
//       return Verse.fromJson(response as Map<String, dynamic>);
//     } catch (e) {
//       print('Error fetching random verse: $e');
//       // يمكنك عرض آية افتراضية في حال حدوث خطأ
//       return Verse(
//         id: 0,
//         surahName: 'خطأ',
//         verseNumber: 0,
//         verseText: 'حدث خطأ أثناء جلب الآية',
//         tafsir: 'يرجى التحقق من اتصالك بالإنترنت.',
//         benefits: '',
//       );
//     }
//   }
// }
// lib/models/verse_model.dart

class Verse {
  final int id;
  final String surahName;
  final int verseNumber;
  final String verseText;
  final String? tafsir;
  final String? benefits;

  Verse({
    required this.id,
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
    this.tafsir,
    this.benefits,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] as int,
      surahName: json['surah_name'] as String,
      verseNumber: json['verse_number'] as int,
      verseText: json['verse_text'] as String,
      tafsir: json['tafsir_muyassar'] as String?,
      benefits: json['benefits'] as String?,
    );
  }

  // --- إضافة جديدة: تحويل الكائن إلى Map ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_name': surahName,
      'verse_number': verseNumber,
      'verse_text': verseText,
      'tafsir_muyassar': tafsir,
      'benefits': benefits,
    };
  }
}
