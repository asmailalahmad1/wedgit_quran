// lib/services/notification_service.dart
import 'dart:io';

import 'package:ayah_wa_taamul/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../models/verse_model.dart';
import 'package:permission_handler/permission_handler.dart'; // أضف هذا الاستيراد

/// A service class to handle all notification-related logic.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_ayah_channel_id_high_priority';
  static const String _channelName = 'آية اليوم (تذكير مهم)';
  static const String _channelDescription = 'إشعارات يومية بآيات وتأملات';

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    styleInformation: BigTextStyleInformation(''),
  );

  static const NotificationDetails _notificationDetails =
      NotificationDetails(android: _androidDetails);

  static Future<void> initializeNotifications() async {
    // يمكنك استخدام @mipmap/ic_launcher إذا لم يكن لديك أيقونة إشعار مخصصة
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    await _requestPermissions();
    await checkBatteryOptimizations(); // أضف هذا الاستدعاء
  }

  static Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.requestNotificationsPermission();
      if (granted == false) {
        debugPrint(
            '-> [NotificationService] إذن الإشعارات لم يُمنح على Android.');
        // يمكنك هنا عرض رسالة للمستخدم لتوجيهه إلى إعدادات التطبيق لتمكين الإذن يدوياً
        // مثال: showDialog(context, builder: ...) أو openAppSettings() من permission_handler
      }
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted == false) {
        debugPrint('-> [NotificationService] إذن الإشعارات لم يُمنح على iOS.');
      }
    }
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      debugPrint('Notification payload: ${response.payload}');
      try {
        final id = int.tryParse(response.payload!);
        if (id != null) {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setInt('tapped_notification_verse_id', id);
          });
        }
      } catch (e) {
        debugPrint('Error saving notification payload: $e');
      }
    }
  }

  static Future<void> scheduleDailyNotificationTask({
    required int hour,
    required int minute,
    required Verse verse,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_surah', verse.surahName);
    await prefs.setInt('notification_verse_num', verse.verseNumber);
    await prefs.setString('notification_verse_text', verse.verseText);
    await prefs.setInt('notification_verse_id', verse.id);

    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    final initialDelay = scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1)).difference(now)
        : scheduledTime.difference(now);

    // إلغاء أي مهام سابقة بنفس المعرف لتجنب التداخل
    await Workmanager().cancelByUniqueName("ayah-notification-task-unique-id");

    await Workmanager().registerPeriodicTask(
      "ayah-notification-task-unique-id",
      "dailyAyahNotification",
      frequency: const Duration(days: 1),
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false, // إضافة وضوح
        requiresDeviceIdle: false, // إضافة وضوح
      ),
      existingWorkPolicy:
          ExistingPeriodicWorkPolicy.replace, // استبدال المهام السابقة
    );
    debugPrint(
        "-> [WorkManager] تم جدولة المهمة اليومية بنجاح. أول تشغيل بعد: $initialDelay");
  }

  static Future<void> showImmediateNotification() async {
    await initializeNotifications();

    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getString('notification_surah') ?? 'سورة';
    final verseNum = prefs.getInt('notification_verse_num') ?? 0;
    final verseText =
        prefs.getString('notification_verse_text') ?? 'تأمل في آيات الله';
    final verseId = prefs.getInt('notification_verse_id') ?? 0;

    await _notificationsPlugin.show(
      0,
      '☀️ آية اليوم: $surah - آية $verseNum',
      verseText,
      _notificationDetails,
      payload: verseId.toString(),
    );
    debugPrint("-> [Notification] Fired immediate notification.");
  }

  // دالة للتحقق من تحسينات البطارية وتوجيه المستخدم
// دالة للتحقق من تحسينات البطارية وتوجيه المستخدم
  static Future<void> checkBatteryOptimizations() async {
    // ✅✅✅ تم التصحيح هنا ✅✅✅
    // نستخدم Platform.isAndroid للتحقق من نظام التشغيل بدون الحاجة لـ context
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isDenied) {
        debugPrint(
            '-> [NotificationService] التطبيق غير مستثنى من تحسينات البطارية.');
        // يمكنك هنا عرض رسالة للمستخدم وتوجيهه إلى الإعدادات
        // مثال: showDialog(context, builder: ...) أو openAppSettings() من permission_handler
      }
    }
  }
}
