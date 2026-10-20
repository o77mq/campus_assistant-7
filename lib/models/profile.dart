import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  final int level;
  final String program;
  final int? group;
  const Profile(this.level, this.program, [this.group]);
}

class ProfileStore {
  static Future<Profile?> load() async {
    final p = await SharedPreferences.getInstance();
    final level = p.getInt('p_level');
    final program = p.getString('p_program');
    if (level == null || program == null) return null;
    final g = p.getInt('p_group');
    return Profile(level, program, g == -1 ? null : g);
  }

  static Future<void> save(Profile pr) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('p_level', pr.level);
    await p.setString('p_program', pr.program);
    await p.setInt('p_group', pr.group ?? -1);
  }
}
