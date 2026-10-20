import 'package:flutter/material.dart';
import '../data/offices.dart';

class WhereToGoScreen extends StatefulWidget {
  const WhereToGoScreen({super.key});
  @override
  State<WhereToGoScreen> createState() => _WhereToGoScreenState();
}

class _WhereToGoScreenState extends State<WhereToGoScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = offices
        .where((o) => o.procedure.contains(_q) || o.office.contains(_q))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('أروح فين؟')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _q = v.trim()),
              decoration: const InputDecoration(
                labelText: 'ابحث عن إجراء',
                hintText: 'مثال: كشف الدرجات',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('مفيش نتائج'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.business_outlined),
                        title: Text(list[i].procedure),
                        subtitle: Text(list[i].office),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => OfficeDetailScreen(office: list[i]))),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class OfficeDetailScreen extends StatelessWidget {
  final Office office;
  const OfficeDetailScreen({super.key, required this.office});

  Widget _section(BuildContext c, String title, IconData icon, List<Widget> kids) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(c).textTheme.titleMedium),
              ]),
              const Divider(),
              ...kids,
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(office.procedure)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(context, 'المكتب والمكان', Icons.place_outlined, [
            Text(office.office, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(office.location),
          ]),
          _section(context, 'الأوراق المطلوبة', Icons.description_outlined, [
            for (final d in office.documents)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(d)),
                ]),
              ),
          ]),
          _section(context, 'خطوات التنفيذ', Icons.format_list_numbered, [
            for (var i = 0; i < office.steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                        radius: 12,
                        child: Text('${i + 1}', style: const TextStyle(fontSize: 12))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(office.steps[i])),
                  ],
                ),
              ),
          ]),
        ],
      ),
    );
  }
}
