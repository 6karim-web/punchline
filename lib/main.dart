import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/joke_repository.dart';
import 'data/journal_repository.dart';
import 'data/profile_repository.dart';
import 'l10n/strings.dart';
import 'screens/journal_screen.dart';
import 'screens/library_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/you_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Profile.instance.load(),
    JournalRepository.instance.load(),
    AppState.instance.load(),
  ]);
  await JokeRepository.instance.load(AppState.instance.locale);
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
        // These delegates give right-to-left for free: Material reads the
        // locale and flips every directional inset in the app.
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

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);

    const screens = [
      LobbyScreen(),
      LibraryScreen(),
      JournalScreen(),
      YouScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: screens),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: T.night,
          border: Border(top: BorderSide(color: T.lineSoft, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: T.night,
          surfaceTintColor: Colors.transparent,
          indicatorColor: T.gold.withValues(alpha: 0.14),
          height: 66,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.theaters_outlined, color: T.faint),
                selectedIcon: const Icon(Icons.theaters, color: T.gold),
                label: s('club')),
            NavigationDestination(
                icon: const Icon(Icons.auto_stories_outlined, color: T.faint),
                selectedIcon: const Icon(Icons.auto_stories, color: T.gold),
                label: s('library')),
            NavigationDestination(
                icon: const Icon(Icons.local_fire_department_outlined,
                    color: T.faint),
                selectedIcon:
                    const Icon(Icons.local_fire_department, color: T.gold),
                label: s('journal')),
            NavigationDestination(
                icon: const Icon(Icons.person_outline, color: T.faint),
                selectedIcon: const Icon(Icons.person, color: T.gold),
                label: s('you')),
          ],
        ),
      ),
    );
  }
}
