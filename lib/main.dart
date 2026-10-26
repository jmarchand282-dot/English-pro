import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnglishProApp());
}

const navy = Color(0xFF171A3A);
const blue = Color(0xFF4F46E5);
const gold = Color(0xFFFFC857);

class EnglishProApp extends StatelessWidget {
  const EnglishProApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'English Pro',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: blue),
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white),
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String level = 'A1';
  int xp = 0;
  final Set<String> completed = {};
  static const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static const lessons = [
    Lesson('Hello! Introducing yourself', 'Greetings and introductions', 'A1', 'Hello! My name is Anna. Nice to meet you.'),
    Lesson('The verb “to be”', 'Build simple sentences', 'A1', 'I am a student. You are my friend. She is happy.'),
    Lesson('Everyday vocabulary', 'Words for daily life', 'A1', 'house = maison • water = eau • friend = ami(e)'),
    Lesson('Talking about your day', 'Simple present tense', 'A1', 'I wake up early. I go to school every day.'),
    Lesson('Past experiences', 'Describe yesterday', 'A2', 'Yesterday, I studied English and played football.'),
    Lesson('Expressing your opinion', 'Give reasons clearly', 'B1', 'In my opinion, learning English creates opportunities.'),
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      xp = p.getInt('xp') ?? 0;
      level = p.getString('level') ?? 'A1';
      completed.addAll(p.getStringList('completed') ?? []);
    });
  }

  Future<void> _saveProgress() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('xp', xp);
    await p.setString('level', level);
    await p.setStringList('completed', completed.toList());
  }

  @override
  Widget build(BuildContext context) {
    final items = lessons.where((l) => l.level == level).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.language, color: gold, size: 29),
          SizedBox(width: 9),
          Text('English Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [IconButton(
          tooltip: 'About',
          icon: const Icon(Icons.info_outline),
          onPressed: () => showAboutDialog(context: context, applicationName: 'English Pro',
            applicationVersion: '1.0.0', children: const [Text('Learn English from A1 to C2. Your progress is saved on this device.')]),
        )],
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [navy, blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('YOUR ENGLISH JOURNEY', style: TextStyle(color: gold, letterSpacing: 1.4, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Small steps.\nBig possibilities.', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 8),
            const Text('Learn at your own pace, every day.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 18),
            Row(children: [
              _stat(Icons.bolt, '$xp XP', 'Your points'),
              const SizedBox(width: 12),
              _stat(Icons.menu_book, '${completed.length}', 'Lessons done'),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Choose your level', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: levels.map((l) => ChoiceChip(
          label: Text(l), selected: level == l,
          onSelected: (_) async {
            setState(() => level = l);
            await _saveProgress();
          },
          selectedColor: blue.withOpacity(0.14),
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: level == l ? blue : navy),
        )).toList()),
        const SizedBox(height: 22),
        const Text('Your lessons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Text('More $level lessons are coming soon. Start with A1 to build strong foundations.'))
        else
          ...items.map(_lessonCard),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.lightbulb_outline, color: blue, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Learning tip: practise for 10 minutes every day. Say new sentences out loud and review what you learned.', style: TextStyle(height: 1.5))),
          ]),
        ),
      ])),
    );
  }

  Widget _stat(IconData icon, String value, String label) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(15)),
    child: Row(children: [
      Icon(icon, color: gold, size: 24),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ])),
    ]),
  ));

  Widget _lessonCard(Lesson lesson) {
    final done = completed.contains(lesson.title);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: done ? Colors.green.shade50 : blue.withOpacity(0.10),
          child: Icon(done ? Icons.check_circle : Icons.menu_book_outlined, color: done ? Colors.green : blue),
        ),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, color: navy)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(lesson.subtitle)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openLesson(lesson),
      ),
    );
  }

  void _openLesson(Lesson lesson) {
    final done = completed.contains(lesson.title);
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(9)))),
          const SizedBox(height: 22),
          Text(lesson.level, style: const TextStyle(color: blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          Text(lesson.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 12),
          Text(lesson.subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          Container(width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(16)),
            child: Text(lesson.example, style: const TextStyle(fontSize: 17, height: 1.6))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: done ? null : () async {
              setState(() { completed.add(lesson.title); xp += 10; });
              await _saveProgress();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            icon: Icon(done ? Icons.check : Icons.stars),
            label: Text(done ? 'Lesson completed' : 'Complete lesson • +10 XP'),
            style: FilledButton.styleFrom(backgroundColor: blue, padding: const EdgeInsets.symmetric(vertical: 15)),
          )),
        ])),
      ),
    );
  }
}

class Lesson {
  final String title, subtitle, level, example;
  const Lesson(this.title, this.subtitle, this.level, this.example);
}
