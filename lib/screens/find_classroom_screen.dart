import 'package:flutter/material.dart';
import '../data/classrooms.dart';
import '../data/courses.dart';

String normalize(String s) {
  const ar = '٠١٢٣٤٥٦٧٨٩';
  var out = s;
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(ar[i], '$i');
  }
  return out.replaceAll(' ', '').replaceAll('-', '').toUpperCase();
}

class FindClassroomScreen extends StatefulWidget {
  const FindClassroomScreen({super.key});
  @override
  State<FindClassroomScreen> createState() => _FindClassroomScreenState();
}

class _FindClassroomScreenState extends State<FindClassroomScreen> {
  String _q = '';
  int? _building;

  List<int> get _buildings =>
      (classrooms.map((c) => c.building).toSet().toList()..sort());

  List<Classroom> get _results {
    final q = normalize(_q);
    return classrooms.where((c) {
      if (_building != null && c.building != _building) return false;
      if (q.isEmpty) return true;
      return normalize(c.number).contains(q);
    }).toList();
  }

  void _show(Classroom c) {
    final names = [
      for (final code in c.courseCodes)
        courses.where((x) => x.code == code).firstOrNull?.name ?? code
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${c.kind} ${c.number}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.apartment),
              title: Text('مبنى ${c.building}'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.stairs_outlined),
              title: Text(c.floorName),
            ),
            const Divider(),
            Text('الاتجاهات:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var i = 0; i < c.directions.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        radius: 12,
                        child: Text('${i + 1}',
                            style: const TextStyle(fontSize: 12))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(c.directions[i])),
                  ],
                ),
              ),
            if (names.isNotEmpty) ...[
              const Divider(),
              Text('بتتدرّس فيها: ${names.join('، ')}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      appBar: AppBar(title: const Text('فين قاعتي؟')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              decoration: const InputDecoration(
                labelText: 'رقم القاعة',
                hintText: 'مثال: 2-1-84 أو 84',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('كل المباني'),
                    selected: _building == null,
                    onSelected: (_) => setState(() => _building = null),
                  ),
                ),
                for (final b in _buildings)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('مبنى $b'),
                      selected: _building == b,
                      onSelected: (_) => setState(() => _building = b),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('مفيش قاعة بالرقم ده'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final c = results[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(c.kind == 'قاعة'
                              ? Icons.meeting_room_outlined
                              : Icons.computer_outlined),
                          title: Text('${c.kind} ${c.number}'),
                          subtitle: Text('مبنى ${c.building} • ${c.floorName}'),
                          trailing: const Icon(Icons.chevron_left),
                          onTap: () => _show(c),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
