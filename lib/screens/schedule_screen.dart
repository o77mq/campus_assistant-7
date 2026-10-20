import 'package:flutter/material.dart';
import '../data/courses.dart';
import '../models/lecture.dart';
import '../models/profile.dart';
import '../services/timetable_sync.dart';
import '../services/notification_service.dart';
import '../services/storage.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Lecture> _items = [];
  Profile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l = await ScheduleStore.load();
    final pr = await ProfileStore.load();
    if (!mounted) return;
    setState(() {
      _items = l;
      _profile = pr;
      _loading = false;
    });
  }

  Future<void> _openForm([Lecture? existing]) async {
    final res = await Navigator.push<Lecture>(context,
        MaterialPageRoute(builder: (_) => LectureFormScreen(lecture: existing, profile: _profile)));
    if (res == null) return;
    final i = _items.indexWhere((e) => e.id == res.id);
    setState(() => i >= 0 ? _items[i] = res : _items.add(res));
    await ScheduleStore.save(_items);
    await NotificationService.schedule(res);
  }

  Future<void> _resync() async {
    final p = _profile;
    if (p == null) return;
    final n = await TimetableSync.apply(p);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('تم تحديث جدولك ($n موعد)')));
  }

  Future<void> _delete(Lecture l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف'),
        content: Text('تحذف ${l.type} ${l.name}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _items.removeWhere((e) => e.id == l.id));
    await ScheduleStore.save(_items);
    await NotificationService.cancel(l);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدولي وتنبيهاتي'),
        actions: [
          if (_profile?.group != null)
            IconButton(
              tooltip: 'إعادة تحميل جدول الكلية',
              icon: const Icon(Icons.sync),
              onPressed: _resync,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('جدولك فاضي. اضغط "إضافة" عشان تسجّل أول محاضرة.',
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  children: [
                    for (final d in weekOrder) ..._dayGroup(d),
                  ],
                ),
    );
  }

  List<Widget> _dayGroup(int day) {
    final list = _items.where((e) => e.day == day).toList()
      ..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
    if (list.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(dayNames[day]!,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      ),
      for (final l in list)
        Card(
          child: ListTile(
            onTap: () => _openForm(l),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(TimeOfDay(hour: l.hour, minute: l.minute).format(context),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                if (l.endHour != null)
                  Text(
                      TimeOfDay(hour: l.endHour!, minute: l.endMinute ?? 0)
                          .format(context),
                      style: const TextStyle(fontSize: 11)),
              ],
            ),
            title: Text('${l.name} (${l.type})'),
            subtitle: Text([
              if (l.room.isNotEmpty) 'القاعة ${l.room}',
              if (l.doctor.isNotEmpty) l.doctor,
            ].join(' • ')),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(l),
            ),
          ),
        ),
    ];
  }
}

class LectureFormScreen extends StatefulWidget {
  final Lecture? lecture;
  final Profile? profile;
  const LectureFormScreen({super.key, this.lecture, this.profile});
  @override
  State<LectureFormScreen> createState() => _LectureFormScreenState();
}

class _LectureFormScreenState extends State<LectureFormScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name, _room, _doctor;
  late String _type;
  late int _day;
  late TimeOfDay _time;
  late int _level;
  late String _program;
  Course? _course;

  @override
  void initState() {
    super.initState();
    final l = widget.lecture;
    _name = TextEditingController(text: l?.name ?? '');
    _room = TextEditingController(text: l?.room ?? '');
    _doctor = TextEditingController(text: l?.doctor ?? '');
    _type = l?.type ?? lectureTypes.first;
    _day = l?.day ?? 6;
    _time = l == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(hour: l.hour, minute: l.minute);
    _level = widget.profile?.level ?? 1;
    _program = widget.profile?.program ?? levelPrograms[_level]!.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _room.dispose();
    _doctor.dispose();
    super.dispose();
  }

  void _pickCourse(Course? c) {
    setState(() {
      _course = c;
      if (c != null) {
        _name.text = c.name;
        _doctor.text = _suggestions.length == 1 ? _suggestions.first : '';
      }
    });
  }

  bool get _isLecturerType => _type == 'محاضرة' || _type == 'تمارين';

  List<String> get _suggestions {
    final c = _course;
    if (c == null) return [];
    return _isLecturerType ? c.lecturers : c.assistants;
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(
      context,
      Lecture(
        id: widget.lecture?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        type: _type,
        day: _day,
        hour: _time.hour,
        minute: _time.minute,
        room: _room.text.trim(),
        doctor: _doctor.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = coursesFor(_level, _program);
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.lecture == null ? 'إضافة موعد' : 'تعديل الموعد')),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
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
                      _course = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('prog-$_level'),
                    initialValue: _program,
                    decoration: const InputDecoration(
                        labelText: 'البرنامج', border: OutlineInputBorder()),
                    items: [
                      for (final p in levelPrograms[_level]!)
                        DropdownMenuItem(value: p, child: Text(p))
                    ],
                    onChanged: (v) => setState(() {
                      _program = v!;
                      _course = null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Course?>(
              key: ValueKey('course-$_level-$_program'),
              initialValue: _course,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'اختار المادة', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<Course?>(
                    value: null, child: Text('مادة أخرى (اكتب الاسم)')),
                for (final c in available)
                  DropdownMenuItem<Course?>(
                      value: c,
                      child: Text('${c.code} - ${c.name}',
                          overflow: TextOverflow.ellipsis)),
              ],
              onChanged: _pickCourse,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'اسم المادة', border: OutlineInputBorder()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'اكتب اسم المادة' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                  labelText: 'النوع', border: OutlineInputBorder()),
              items: [
                for (final t in lectureTypes)
                  DropdownMenuItem(value: t, child: Text(t))
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _day,
              decoration: const InputDecoration(
                  labelText: 'اليوم', border: OutlineInputBorder()),
              items: [
                for (final d in weekOrder)
                  DropdownMenuItem(value: d, child: Text(dayNames[d]!))
              ],
              onChanged: (v) => setState(() => _day = v!),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text('الوقت: ${_time.format(context)}'),
              onPressed: () async {
                final t =
                    await showTimePicker(context: context, initialTime: _time);
                if (t != null) setState(() => _time = t);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _room,
              decoration: const InputDecoration(
                  labelText: 'القاعة (اختياري)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _doctor,
              decoration: InputDecoration(
                  labelText: _isLecturerType
                      ? 'اسم الدكتور (اختياري)'
                      : 'اسم المعيد / الدكتور (اختياري)',
                  border: const OutlineInputBorder()),
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final n in _suggestions)
                    ActionChip(
                      label: Text(n),
                      onPressed: () => setState(() => _doctor.text = n),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('حفظ')),
          ],
        ),
      ),
    );
  }
}
