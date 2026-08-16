import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/joke_repository.dart';
import 'l10n/strings.dart';
import 'screens/brief_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/markets_screen.dart';
import 'screens/more_screen.dart';
import 'screens/punchline_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notifications.dart';
import 'data/notes_repository.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications.instance.init();
  await Future.wait([
    JokeRepository.instance.load(),
    NotesRepository.instance.load(),
    AppState.instance.load(),
  ]);
  runApp(const PunchlineApp());
}

class PunchlineApp extends StatelessWidget {
  const PunchlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) => MaterialApp(
        title: 'Punchline',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: AppState.instance.locale.locale,
        // These delegates are what give us right-to-left for free: Material
        // reads the locale and flips every directional inset in the app.
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), Locale('es'), Locale('fr'), Locale('ar'),
        ],
        home: const Shell(),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  void _open(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final titles = [
      s('brief'), s('punchline'), s('markets'), s('news'), s('more'),
    ];

    final screens = [
      BriefScreen(onOpenTab: _open),
      const PunchlineScreen(),
      const MarketsScreen(),
      const FeedScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, size: 20, color: T.textMuted),
            onPressed: () => SettingsSheet.show(context),
          ),
        ],
        shape: const Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: T.border, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _open,
          backgroundColor: T.canvas,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          height: 62,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.wb_twilight, color: T.textFaint),
                selectedIcon: const Icon(Icons.wb_twilight, color: T.text),
                label: s('brief')),
            NavigationDestination(
                icon: const Icon(Icons.mood_outlined, color: T.textFaint),
                selectedIcon: const Icon(Icons.mood_outlined, color: T.text),
                label: s('punchline')),
            NavigationDestination(
                icon: const Icon(Icons.show_chart, color: T.textFaint),
                selectedIcon: const Icon(Icons.show_chart, color: T.text),
                label: s('markets')),
            NavigationDestination(
                icon: const Icon(Icons.article_outlined, color: T.textFaint),
                selectedIcon: const Icon(Icons.article_outlined, color: T.text),
                label: s('news')),
            NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined, color: T.textFaint),
                selectedIcon:
                    const Icon(Icons.grid_view_outlined, color: T.text),
                label: s('more')),
          ],
        ),
      ),
    );
  }
}
