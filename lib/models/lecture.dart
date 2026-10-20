import 'dart:convert';

/// أيام الأسبوع بترتيب الأسبوع الدراسي (السبت أولاً). القيم = DateTime.weekday
const List<int> weekOrder = [6, 7, 1, 2, 3, 4, 5];
const Map<int, String> dayNames = {
  6: 'السبت',
  7: 'الأحد',
  1: 'الاثنين',
  2: 'الثلاثاء',
  3: 'الأربعاء',
  4: 'الخميس',
  5: 'الجمعة',
};
const List<String> lectureTypes = ['محاضرة', 'سكشن', 'لاب', 'تمارين', 'تدريب'];

class Lecture {
  final String id;
  final String name;
  final String type;
  final int day; // DateTime.weekday
  final int hour;
  final int minute;
  final String room;
  final String doctor;
  final int? endHour;
  final int? endMinute;
  final bool auto; // اتحط تلقائي من جدول الكلية

  const Lecture({
    required this.id,
    required this.name,
    required this.type,
    required this.day,
    required this.hour,
    required this.minute,
    this.room = '',
    this.doctor = '',
    this.endHour,
    this.endMinute,
    this.auto = false,
  });

  int get minutesOfDay => hour * 60 + minute;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'day': day,
        'hour': hour,
        'minute': minute,
        'room': room,
        'doctor': doctor,
        'endHour': endHour,
        'endMinute': endMinute,
        'auto': auto,
      };

  factory Lecture.fromJson(Map<String, dynamic> j) => Lecture(
        id: j['id'],
        name: j['name'],
        type: j['type'],
        day: j['day'],
        hour: j['hour'],
        minute: j['minute'],
        room: j['room'] ?? '',
        doctor: j['doctor'] ?? '',
        endHour: j['endHour'],
        endMinute: j['endMinute'],
        auto: j['auto'] ?? false,
      );

  static String encodeList(List<Lecture> l) =>
      jsonEncode(l.map((e) => e.toJson()).toList());

  static List<Lecture> decodeList(String s) => (jsonDecode(s) as List)
      .map((e) => Lecture.fromJson(e as Map<String, dynamic>))
      .toList();
}
