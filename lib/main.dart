import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/courses.dart';
import 'models/profile.dart';
import 'screens/find_classroom_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/where_to_go_screen.dart';
import 'services/notification_service.dart';
import 'services/timetable_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.init();
  } catch (_) {}
  runApp(const CampusApp());
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'وجّهني',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 227, 0, 0),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ProfileStore.load();
    if (!mounted) return;
    setState(() => _profile = p);
    if (p == null || p.group == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _editProfile();
      });
    }
  }

  Future<void> _editProfile() async {
    final res = await Navigator.push<Profile>(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen(initial: _profile)));
    if (res == null) return; 
    await ProfileStore.save(res);
    if (mounted) setState(() => _profile = res);
    final n = await TimetableSync.apply(res);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(n > 0
            ? 'تم تحميل جدولك ($n موعد) وضبط التنبيهات تلقائي ✅'
            : 'مفيش مواعيد متاحة للجروب ده حالياً'),
      ));
    }
  } 
  

  @override
  Widget build(BuildContext context) {
    final items = [
      _Feature(Icons.meeting_room_outlined, 'فين قاعتي؟', 'Find My Classroom',
          'اعرف مكان القاعة والاتجاهات خطوة بخطوة', const FindClassroomScreen()),
      _Feature(Icons.calendar_month_outlined, 'جدولي وتنبيهاتي',
          'My Schedule & Weekly Reminders',
          'نظّم محاضراتك واستلم تنبيه قبلها بـ 10 دقائق', const ScheduleScreen()),
      _Feature(Icons.assistant_direction_outlined, 'أروح فين؟',
          'Where Should I Go?',
          'اعرف المكتب المناسب والأوراق المطلوبة', const WhereToGoScreen()),
    ];
    final p = _profile;
    final profileText = p == null
        ? 'اختار سنتك الدراسية'
        : '${levelNames[p.level]} • ${p.program}${p.group != null ? ' • جروب ${p.group}' : ''}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('وجّهني'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('أهلاً بيك في الجامعة 👋',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.school_outlined),
              title: Text(profileText),
              subtitle: const Text('دوس عشان تغيّر السنة أو البرنامج'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _editProfile,
            ),
          ),
          const SizedBox(height: 12),
          Text('اختار اللي محتاجه:',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          for (final f in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => f.screen)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(f.icon, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.title,
                                  style: Theme.of(context).textTheme.titleLarge),
                              Text(f.en,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: const Color.fromARGB(255, 0, 0, 0)),
                                  textDirection: TextDirection.ltr),
                              const SizedBox(height: 4),
                              Text(f.desc),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title, en, desc;
  final Widget screen;
  _Feature(this.icon, this.title, this.en, this.desc, this.screen);
}
