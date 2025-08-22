// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verse_model.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = true;
  bool _isScheduling = false;

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour') ?? 8;
    final minute = prefs.getInt('notification_minute') ?? 0;
    if (mounted) {
      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndReschedule(TimeOfDay newTime) async {
    if (mounted) {
      setState(() {
        _isScheduling = true;
      });
    }

    try {
      debugPrint("-> [Settings] جاري جلب آية لجدولة الإشعار...");
      final supabase = Supabase.instance.client;
      final response = await supabase.rpc('get_random_verse').single();
      final verse = Verse.fromJson(response);
      debugPrint("-> [Settings] تم جلب الآية بنجاح.");

      // ❌❌❌ تم حذف Workmanager().initialize() من هنا بالكامل ❌❌❌
      // نستدعي الجدولة مباشرة
      await NotificationService.scheduleDailyNotificationTask(
        hour: newTime.hour,
        minute: newTime.minute,
        verse: verse,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_hour', newTime.hour);
      await prefs.setInt('notification_minute', newTime.minute);
      await prefs.setInt('verse_id', verse.id);
      await prefs.setString('verse_text', verse.verseText);
      await prefs.setString('surah_name', verse.surahName);
      await prefs.setInt('verse_number', verse.verseNumber);
      debugPrint(
          "-> [Settings] تم حفظ بيانات الآية والتوقيت في SharedPreferences.");

      if (mounted) {
        setState(() {
          _selectedTime = newTime;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم ضبط الإشعار اليومي على الساعة ${newTime.format(context)}',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("-> [Settings] ❌ فشل في جدولة الإشعار: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جدولة الإشعار. يرجى إعادة المحاولة.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScheduling = false;
        });
      }
    }
  }

  void _openTimePicker() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: 'اختر وقت الإشعار اليومي',
      cancelText: 'إلغاء',
      confirmText: 'حفظ',
    );

    if (newTime != null) {
      _saveAndReschedule(newTime);
    }
  }

  Future<void> _requestBatteryOptimizationPermission() async {
    var status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isDenied) {
      if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'شكراً لك! تمكين هذا الإذن يساعد على وصول الإشعارات في وقتها.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications_active_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        'وقت الإشعار اليومي',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        'سيتم إرسال آية كل يوم في الساعة ${_selectedTime.format(context)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: _isScheduling
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                      onTap: _isScheduling ? null : _openTimePicker,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.battery_alert_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'لضمان وصول الإشعارات',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'بعض أنظمة أندرويد توقف التطبيقات في الخلفية للحفاظ على البطارية، مما قد يمنع وصول الإشعارات في وقتها. يرجى منح التطبيق الإذن للعمل بحرية.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: _requestBatteryOptimizationPermission,
                              child: const Text('منح إذن البطارية'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              right: 16.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              'مظهر التطبيق',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          _buildThemeRadioTile(
                            title: 'الوضع الفاتح',
                            value: ThemeMode.light,
                            groupValue: currentThemeMode,
                            onChanged: (v) => ref
                                .read(themeProvider.notifier)
                                .changeTheme(v!),
                          ),
                          _buildThemeRadioTile(
                            title: 'الوضع الداكن',
                            value: ThemeMode.dark,
                            groupValue: currentThemeMode,
                            onChanged: (v) => ref
                                .read(themeProvider.notifier)
                                .changeTheme(v!),
                          ),
                          _buildThemeRadioTile(
                            title: 'افتراضي (حسب النظام)',
                            value: ThemeMode.system,
                            groupValue: currentThemeMode,
                            onChanged: (v) => ref
                                .read(themeProvider.notifier)
                                .changeTheme(v!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildThemeRadioTile({
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required void Function(ThemeMode?) onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}
