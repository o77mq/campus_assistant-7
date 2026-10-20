import '../data/courses.dart';
import '../data/timetable.dart';
import '../models/lecture.dart';
import '../models/profile.dart';
import 'notification_service.dart';
import 'storage.dart';

/// بيملأ "جدولي" من جدول الكلية حسب السنة والجروب، وبيظبط التنبيهات تلقائي.
class TimetableSync {
  /// بيرجع عدد المواعيد اللي اتضافت.
  static Future<int> apply(Profile p) async {
    final g = p.group;
    if (g == null) return 0;

    final current = await ScheduleStore.load();
    for (final l in current.where((l) => l.auto)) {
      await NotificationService.cancel(l);
    }
    final manual = current.where((l) => !l.auto).toList();

    final fresh = <Lecture>[];
    var n = 0;
    for (final e in entriesFor(p.level, g)) {
      final course = courses.where((c) => c.code == e.code).firstOrNull;
      final st = slotStarts[e.s1 - 1];
      final en = slotEnds[e.s2 - 1];
      fresh.add(Lecture(
        id: 'auto-${e.day}-${p.level}-$g-${e.s1}-${e.code}-${e.type}-${n++}',
        name: course?.name ?? e.code,
        type: typeNames[e.type] ?? 'محاضرة',
        day: e.day,
        hour: st[0],
        minute: st[1],
        endHour: en[0],
        endMinute: en[1],
        room: e.room,
        doctor: e.doctor,
        auto: true,
      ));
    }

    await ScheduleStore.save([...manual, ...fresh]);
    for (final l in fresh) {
      await NotificationService.schedule(l);
    }
    return fresh.length;
  }
}
