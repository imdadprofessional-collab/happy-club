import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/quotes_data.dart';

/// Three fixed daily local-time reminders (morning / midday / evening),
/// each carrying a rotating quote from [QuotesData] so the nudge doesn't
/// feel identical every day.
class _ReminderSlot {
  const _ReminderSlot({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
  });

  final int id;
  final int hour;
  final int minute;
  final String title;
}

/// Schedules the app's daily check-in notifications via
/// `flutter_local_notifications`. Uses `AndroidScheduleMode.inexactAllowWhileIdle`
/// deliberately — it doesn't require the user to grant the separate
/// "Alarms & reminders" (`SCHEDULE_EXACT_ALARM`) permission on Android 12+,
/// trading exact-minute delivery for a simpler, permission-light setup that
/// suits a gentle daily nudge rather than a time-critical alarm.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'happy_club_daily';
  static const String _channelName = 'Daily reminders';
  static const String _channelDescription =
      'Gentle nudges to check in, reflect, and keep your streak alive.';

  static const List<_ReminderSlot> _slots = [
    _ReminderSlot(id: 100, hour: 9, minute: 0, title: 'Good morning ☀️'),
    _ReminderSlot(id: 101, hour: 14, minute: 0, title: 'Midday check-in 🌿'),
    _ReminderSlot(id: 102, hour: 20, minute: 0, title: 'Evening reflection 🌙'),
  ];

  /// Initializes the plugin (once), requests notification permission, and
  /// (re)schedules the daily reminders. Safe to call repeatedly (e.g. every
  /// app launch) and safe on hosts with no notification platform channel at
  /// all — `flutter test`'s runner, desktop — where every step is a no-op
  /// caught by the outer try/catch rather than throwing during startup.
  Future<void> initAndSchedule() async {
    try {
      if (!_initialized) {
        tz.initializeTimeZones();
        try {
          final localTz = await FlutterTimezone.getLocalTimezone();
          final name = localTz.identifier;
          tz.setLocalLocation(tz.getLocation(name));
        } catch (_) {
          // Falls back to whatever default `timezone` already picked (UTC).
        }

        const androidInit = AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
        const iosInit = DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: androidInit,
            iOS: iosInit,
          ),
        );
        _initialized = true;
      }

      await _requestPermission();
      await _scheduleAll();
    } catch (_) {
      // Notifications are a nice-to-have; never block app startup on them.
    }
  }

  Future<void> _requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _scheduleAll() async {
    await _plugin.cancelAll();
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;

    for (final slot in _slots) {
      await _plugin.zonedSchedule(
        id: slot.id,
        title: slot.title,
        body: QuotesData.forDay(dayOfYear + slot.id),
        scheduledDate: _nextInstanceOf(slot.hour, slot.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Turns off all scheduled reminders (e.g. if a future settings screen
  /// lets the user opt out).
  Future<void> cancelAll() => _plugin.cancelAll();
}
