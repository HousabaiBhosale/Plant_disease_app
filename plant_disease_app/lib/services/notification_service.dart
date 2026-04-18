import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart' show Color;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Notification channels ──────────────────────────────────
  static const _diseaseChannel = AndroidNotificationChannel(
    'disease_alerts',
    'Disease Risk Alerts',
    description: 'Alerts when weather conditions are high risk for crop diseases',
    importance: Importance.high,
  );

  static const _weatherChannel = AndroidNotificationChannel(
    'weather_advisory',
    'Weather Advisory',
    description: 'Daily farming weather advisories',
    importance: Importance.defaultImportance,
  );

  static const _scanChannel = AndroidNotificationChannel(
    'scan_reminders',
    'Scan Reminders',
    description: 'Reminders to scan your crops regularly',
    importance: Importance.low,
  );

  // ── Initialize ─────────────────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings     = DarwinInitializationSettings(
      requestAlertPermission:  true,
      requestBadgePermission:  true,
      requestSoundPermission:  true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onTap,
    );

    // Create channels
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_diseaseChannel);
    await android?.createNotificationChannel(_weatherChannel);
    await android?.createNotificationChannel(_scanChannel);

    // Request permission
    await android?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onTap(NotificationResponse response) {
    // Handle notification tap — navigation handled in main.dart
  }

  // ── Request permission ─────────────────────────────────────
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  // ── Show disease risk alert (immediate) ───────────────────
  Future<void> showDiseaseRiskAlert({
    required String title,
    required String body,
    String risk = 'High',
  }) async {
    await _plugin.show(
      1001,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _diseaseChannel.id,
          _diseaseChannel.name,
          channelDescription: _diseaseChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF1E8049),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Show weather advisory ──────────────────────────────────
  Future<void> showWeatherAdvisory({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      1002,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _weatherChannel.id,
          _weatherChannel.name,
          channelDescription: _weatherChannel.description,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF2D84C8),
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  // ── Show scan reminder ─────────────────────────────────────
  Future<void> showScanReminder() async {
    await _plugin.show(
      1003,
      '🌿 Time to scan your crops!',
      'Regular scanning helps catch diseases early. Tap to open PlantGuard.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _scanChannel.id,
          _scanChannel.name,
          channelDescription: _scanChannel.description,
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF1E8049),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  // ── Schedule daily morning advisory (8 AM) ────────────────
  Future<void> scheduleDailyAdvisory() async {
    await _plugin.zonedSchedule(
      2001,
      '🌾 Good morning! Daily Farm Advisory',
      'Check today\'s disease risk and weather conditions for your crops.',
      _nextInstanceOfTime(8, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _weatherChannel.id,
          _weatherChannel.name,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF1E8049),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  // ── Schedule weekly scan reminder (Monday 9 AM) ────────────
  Future<void> scheduleWeeklyScanReminder() async {
    await _plugin.zonedSchedule(
      2002,
      '📷 Weekly Crop Check Reminder',
      'It\'s been a week! Scan your crops to catch any early disease signs.',
      _nextInstanceOfWeekday(DateTime.monday, 9, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _scanChannel.id,
          _scanChannel.name,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF1E8049),
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // ── Cancel all notifications ───────────────────────────────
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Cancel specific notification ──────────────────────────
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  // ── Check weather and send alert if needed ─────────────────
  Future<void> checkWeatherAndAlert({
    required double humidity,
    required double tempC,
    required String condition,
    required String cityName,
  }) async {
    // Very high risk
    if (humidity >= 80 && tempC >= 20) {
      await showDiseaseRiskAlert(
        title: '⚠️ VERY HIGH Disease Risk in $cityName',
        body: 'Humidity ${humidity.toStringAsFixed(0)}% + ${tempC.toStringAsFixed(0)}°C — '
            'Critical conditions for late blight, powdery mildew and fungal infections. '
            'Apply fungicide IMMEDIATELY on tomatoes, potatoes and grapes!',
        risk: 'Very High',
      );
    }
    // High risk
    else if (humidity >= 70 && tempC >= 18) {
      await showDiseaseRiskAlert(
        title: '🌧 High Disease Risk — Take Action',
        body: 'Humidity ${humidity.toStringAsFixed(0)}% in $cityName — '
            'Good conditions for fungal spread. Apply preventive fungicide '
            'on your crops before rain arrives.',
        risk: 'High',
      );
    }
    // Rain advisory
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('thunder')) {
      await showWeatherAdvisory(
        title: '🌧 Rain Expected — Farming Advisory',
        body: 'Rain forecast in $cityName. Skip irrigation, avoid spraying pesticides. '
            'Ensure good drainage around crop roots.',
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now  = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    var scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
