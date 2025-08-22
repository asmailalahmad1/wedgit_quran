// lib/providers/connectivity_provider.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// هذا الـ Provider سيقوم ببث (stream) حالة الاتصال بالشبكة
// في كل مرة تتغير فيها الحالة (متصل/غير متصل)
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) => results.first);
});
