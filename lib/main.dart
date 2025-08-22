// lib/main.dart

// --- 1. Flutter Core & Riverpod ---
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // لـ kDebugMode

// --- 2. Third-party Packages ---
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

// --- 3. Project Files ---
import 'models/verse_model.dart';
import 'providers/theme_provider.dart';
import 'providers/verse_provider.dart' show verseProvider;
import 'providers/widget_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'themes/app_themes.dart';

// =========================================================================
//                             Global Keys & Providers
// =========================================================================

final messengerKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();
final initialVerseIdProvider = StateProvider<int?>((ref) => null);

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint("-> [WorkManager] تشغيل مهمة الخلفية: $task");
      if (task == "dailyAyahNotification") {
        await NotificationService.showImmediateNotification();
        debugPrint("-> [WorkManager] تم عرض الإشعار بنجاح.");
        return Future.value(true);
      } else {
        debugPrint("-> [WorkManager] مهمة غير معروفة: $task");
        return Future.value(false);
      }
    } catch (err) {
      debugPrint("-> [WorkManager] ❌ خطأ في مهمة الخلفية: $err");
      return Future.value(false);
    }
  });
}

// =========================================================================
//                           ✅ 1. Provider التهيئة ✅
// =========================================================================
/// هذا الـ Provider مسؤول عن تنفيذ كل عمليات التهيئة الأساسية.
/// لن يتم بناء واجهة التطبيق الرئيسية إلا بعد اكتمال هذا الـ Provider بنجاح.
final appInitializationProvider = FutureProvider<void>((ref) async {
  // التأكد من تهيئة الارتباطات الأساسية للفلاتر
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة WorkManager وانتظار اكتماله
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  // تهيئة بقية الخدمات (Supabase, Notifications, HomeWidget)
  await _initializeAppServices();

  // التعامل مع فتح التطبيق من إشعار وهو مغلق تمامًا
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    if (notificationAppLaunchDetails!.notificationResponse?.payload != null) {
      final id = int.tryParse(
          notificationAppLaunchDetails.notificationResponse!.payload!);
      if (id != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('tapped_notification_verse_id', id);
      }
    }
  }
});

// =========================================================================
//                         ✅ 2. نقطة الدخول الرئيسية (Main) ✅
// =========================================================================
/// أصبحت دالة main الآن بسيطة جداً، ووظيفتها فقط تشغيل التطبيق.
void main() {
  runApp(const ProviderScope(child: AppInitializer()));
}

// =========================================================================
//                     ✅ 3. ويدجت التهيئة والتحميل ✅
// =========================================================================
/// هذه الويدجت تعمل كبوابة.
/// تراقب حالة provider التهيئة، وتعرض شاشة تحميل أو خطأ أو التطبيق الرئيسي.
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(appInitializationProvider);

    return initialization.when(
      // في حالة اكتمال التهيئة بنجاح، يتم عرض التطبيق الرئيسي
      data: (_) => const MyApp(),

      // أثناء التحميل، يتم عرض مؤشر تحميل
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),

      // في حالة حدوث خطأ أثناء التهيئة، يتم عرض رسالة خطأ
      error: (error, stackTrace) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'فشل في تهيئة التطبيق:\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// دالة مساعدة لتنظيم عملية تهيئة الخدمات.
Future<void> _initializeAppServices() async {
  await Supabase.initialize(
    url: "https://ilzttizoyuqdsacapybs.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlsenR0aXpveXVxZHNhY2FweWJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4MTQzNjgsImV4cCI6MjA3MDM5MDM2OH0.5uPtYJdFRci5LiE1LftYk3STn3jdTVbLw5UxoV8MfWY",
  );
  await NotificationService.initializeNotifications();
  HomeWidget.registerBackgroundCallback(updateWidget);
}

// =========================================================================
//                            التطبيق الرئيسي: MyApp
// =========================================================================
/// هذا هو التطبيق الرئيسي الخاص بك. لم يتم تعديل أي شيء هنا.
/// سيتم بناؤه فقط بعد نجاح التهيئة.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForTappedNotification();
    _setupWidgetClickListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkForTappedNotification();
    }
  }

  void _checkForTappedNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('tapped_notification_verse_id');

    if (id != null) {
      debugPrint("-> [MyAppState] تم العثور على نقرة إشعار لـ ID: $id");
      ref.read(initialVerseIdProvider.notifier).state = id;
      ref.invalidate(verseProvider);
      await prefs.remove('tapped_notification_verse_id');
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  void _setupWidgetClickListener() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetUri);
    HomeWidget.widgetClicked.listen(_handleWidgetUri);
  }

  void _handleWidgetUri(Uri? uri) {
    if (uri != null && uri.scheme == 'ayah_widget') {
      final id = int.tryParse(uri.queryParameters['id'] ?? '');
      if (id != null && id != -1) {
        debugPrint("-> [MyAppState] تم العثور على نقرة ويدجت لـ ID: $id");
        ref.read(initialVerseIdProvider.notifier).state = id;
        ref.invalidate(verseProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'آية وتأمل',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      navigatorKey: navigatorKey,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      home: HomeScreen(),
    );
  }
}
