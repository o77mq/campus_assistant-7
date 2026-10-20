import 'package:shared_preferences/shared_preferences.dart';
import '../models/lecture.dart';

class ScheduleStore {
  static const _key = 'lectures';

  static Future<List<Lecture>> load() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    if (s == null || s.isEmpty) return [];
    return Lecture.decodeList(s);
  }

  static Future<void> save(List<Lecture> l) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, Lecture.encodeList(l));
  }
}
