import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../providers/persona_provider.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final _plugin = FlutterLocalNotificationsPlugin();
  static const int _dailyReminderId = 1;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleDailyReminder({
    required Persona persona,
    required int hour,
    required int minute,
  }) async {
    await cancelAll();

    final String title;
    final String body;

    switch (persona) {
      case Persona.nino:
        title = '¡English Bridge! 🌟';
        body = '¡Hora de practicar! 🌟 Tus amigos ya están aprendiendo inglés.';
      case Persona.adulto:
        title = '¡English Bridge! 🎯';
        body = '5 minutos de inglés hoy para un mejor trabajo mañana.';
      case Persona.abuelo:
        title = '¡English Bridge! ⭐';
        body = 'Es hora de tu práctica diaria para hablar con tus nietos.';
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Recordatorio diario',
      channelDescription: 'Recordatorio para practicar inglés cada día',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyReminderId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels today's scheduled notification.
  /// On next app launch, main.dart will re-schedule it.
  Future<void> cancelToday() async {
    await _plugin.cancel(_dailyReminderId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
