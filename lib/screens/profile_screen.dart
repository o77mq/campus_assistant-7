import 'package:flutter/material.dart';
import '../data/courses.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  final Profile? initial;
  const ProfileScreen({super.key, this.initial});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int _level;
  late String _program;
  late int _group;

  @override
  void initState() {
    super.initState();
    _level = widget.initial?.level ?? 1;
    _program = widget.initial?.program ?? levelPrograms[_level]!.first;
    final groups = groupsFor(_level, _program);
    final g = widget.initial?.group;
    _group = (g != null && groups.contains(g)) ? g : groups.first;
  }

  void _fixGroup() {
    final groups = groupsFor(_level, _program);
    if (!groups.contains(_group)) _group = groups.first;
  }

  @override
  Widget build(BuildContext context) {
    final programs = levelPrograms[_level]!;
    final groups = groupsFor(_level, _program);
    return Scaffold(
      appBar: AppBar(title: const Text('سنتي الدراسية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('اختار سنتك وبرنامجك وجروبك، وجدولك هيتملأ لوحده '
              'والتنبيهات هتتظبط تلقائي قبل كل محاضرة بـ 10 دقايق.'),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _level,
            decoration: const InputDecoration(
                labelText: 'السنة', border: OutlineInputBorder()),
            items: [
              for (final e in levelNames.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value))
            ],
            onChanged: (v) => setState(() {
              _level = v!;
              if (!levelPrograms[_level]!.contains(_program)) {
                _program = levelPrograms[_level]!.first;
              }
              _fixGroup();
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey('prog-$_level'),
            initialValue: _program,
            decoration: const InputDecoration(
                labelText: 'البرنامج', border: OutlineInputBorder()),
            items: [
              for (final p in programs) DropdownMenuItem(value: p, child: Text(p))
            ],
            onChanged: (v) => setState(() {
              _program = v!;
              _fixGroup();
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            key: ValueKey('group-$_level-$_program'),
            initialValue: _group,
            decoration: const InputDecoration(
                labelText: 'الجروب', border: OutlineInputBorder()),
            items: [
              for (final g in groups)
                DropdownMenuItem(value: g, child: Text('جروب $g'))
            ],
            onChanged: (v) => setState(() => _group = v!),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, Profile(_level, _program, _group)),
            child: const Text('حفظ وتحميل جدولي'),
          ),
        ],
      ),
    );
  }
}
