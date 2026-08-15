import 'package:flutter/material.dart';
import 'screens/feed_screen.dart';
import 'screens/markets_screen.dart';
import 'screens/more_screen.dart';
import 'screens/punchline_screen.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

void main() => runApp(const PunchlineApp());

class PunchlineApp extends StatelessWidget {
  const PunchlineApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Punchline',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  static const _titles = ['Today', 'Punchline', 'Markets', 'More'];
  static const _screens = [
    FeedScreen(),
    PunchlineScreen(),
    MarketsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: T.s4),
            child: Icon(Icons.notifications_none, size: 20, color: T.textMuted),
          ),
        ],
        shape: const Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: T.border, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: T.canvas,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          height: 62,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined, color: T.textFaint),
                selectedIcon: Icon(Icons.home_outlined, color: T.text),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.mood_outlined, color: T.textFaint),
                selectedIcon: Icon(Icons.mood_outlined, color: T.text),
                label: 'Punchline'),
            NavigationDestination(
                icon: Icon(Icons.show_chart, color: T.textFaint),
                selectedIcon: Icon(Icons.show_chart, color: T.text),
                label: 'Markets'),
            NavigationDestination(
                icon: Icon(Icons.more_horiz, color: T.textFaint),
                selectedIcon: Icon(Icons.more_horiz, color: T.text),
                label: 'More'),
          ],
        ),
      ),
    );
  }
}
