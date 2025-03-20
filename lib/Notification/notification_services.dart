import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
    DarwinInitializationSettings();
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings, iOS: iosInitSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'chanel',
        'Scheduled Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String repeatFrequency,
  }) async {
    tz.TZDateTime scheduleDate = tz.TZDateTime.from(scheduledTime, tz.local);

    switch (repeatFrequency) {
      case "Daily":
        scheduleDate = scheduleDate.add(const Duration(days: 1));
        break;
      case "Weekly":
        scheduleDate = scheduleDate.add(const Duration(days: 7));
        break;
      case "Monthly":
        scheduleDate = tz.TZDateTime(
          tz.local,
          scheduleDate.year,
          scheduleDate.month + 1,
          scheduleDate.day,
          scheduleDate.hour,
          scheduleDate.minute,
        );
        break;
      case "Yearly":
        scheduleDate = tz.TZDateTime(
          tz.local,
          scheduleDate.year + 1,
          scheduleDate.month,
          scheduleDate.day,
          scheduleDate.hour,
          scheduleDate.minute,
        );
        break;
      default:
        break;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatFrequency == "Daily"
          ? DateTimeComponents.time
          : repeatFrequency == "Weekly"
          ? DateTimeComponents.dayOfWeekAndTime
          : repeatFrequency == "Monthly"
          ? DateTimeComponents.dayOfMonthAndTime
          : repeatFrequency == "Yearly"
          ? DateTimeComponents.dateAndTime
          : null,
    );
  }
}
