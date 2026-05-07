import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../utils/app_text.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _dailyReminderId = 1001;
  static const String _channelId = 'daily_reminder_channel';
  static const String _channelName = 'Daily reminders';
  static const String _channelDescription = 'Daily app usage reminders';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings: initSettings);
    await _requestAndroidPermissions();
  }

  Future<void> scheduleDailyReminder({required String lang}) async {
    await _notifications.cancel(id: _dailyReminderId);

    final now = tz.TZDateTime.now(tz.local);
    var nextReminderTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      2,
      16,
    );

    if (!nextReminderTime.isAfter(now)) {
      nextReminderTime = nextReminderTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: _dailyReminderId,
      title: AppText.get(lang, 'daily_reminder_title'),
      body: AppText.get(lang, 'daily_reminder_body'),
      scheduledDate: nextReminderTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showTestNotification({required String lang}) async {
    await _notifications.show(
      id: 2001,
      title: AppText.get(lang, 'daily_reminder_title'),
      body: AppText.get(lang, 'daily_reminder_body'),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _requestAndroidPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }
}
