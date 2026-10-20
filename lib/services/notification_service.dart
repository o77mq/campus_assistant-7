import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/lecture.dart';

/// تنبيه أسبوعي متكرر قبل كل محاضرة/سكشن بـ 10 دقائق.
class NotificationService {
  static const int minutesBefore = 10;
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    // توقيت مصر (القاهرة) ثابت للتطبيق.
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
        settings: const InitializationSettings(android: android));

    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await impl?.requestNotificationsPermission();
    await impl?.requestExactAlarmsPermission();
  }

  static int _nid(Lecture l) {
    var h = 0x811c9dc5;
    for (final c in l.id.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }

  static tz.TZDateTime _nextTrigger(Lecture l) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, l.hour, l.minute)
        .subtract(const Duration(minutes: minutesBefore));
    while (t.weekday != l.day || !t.isAfter(now)) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }

  static Future<void> schedule(Lecture l) async {
    try {
      await _plugin.cancel(id: _nid(l));
      final where = l.room.isEmpty ? '' : ' في القاعة ${l.room}';
      await _plugin.zonedSchedule(
        id: _nid(l),
        title: 'تذكير: ${l.name}',
        body: 'تبدأ ${l.type} ${l.name} بعد $minutesBefore دقائق$where',
        scheduledDate: _nextTrigger(l),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'lectures_channel',
            'تذكيرات المحاضرات',
            channelDescription: 'تنبيه قبل موعد كل محاضرة أو سكشن',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (_) {
      // لو الإذن مش متاح، التطبيق يكمل شغل بدون تنبيه.
    }
  }

  static Future<void> cancel(Lecture l) => _plugin.cancel(id: _nid(l));
}
