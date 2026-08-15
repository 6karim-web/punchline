import '../models/models.dart';

/// Placeholder content so the shell runs before Supabase is wired up.
/// Delete this file once the repositories are live.
class Sample {
  Sample._();

  static const jokes = <Joke>[
    Joke(
      id: '1',
      title: 'Scientific dating',
      setup:
          'At a museum, a visitor asks the age of a dinosaur skeleton. '
          '"Six million years, five months, and three days." '
          '"How can you be so precise?"',
      punchline:
          '"When I started working here five months and three days ago, '
          'they said it was six million years old."',
      category: 'work',
      shares: 2418,
    ),
    Joke(
      id: '2',
      title: 'The exit interview',
      setup: 'HR asked why I was leaving. I said, "For a company that values '
          'honesty." They said, "We value honesty."',
      punchline: 'I said, "No, you value exit interviews."',
      category: 'work',
      shares: 1903,
    ),
    Joke(
      id: '3',
      title: 'Unlimited vacation',
      setup: 'Our company offers unlimited vacation.',
      punchline:
          'You can take as much time as you want between being fired and '
          'finding another job.',
      category: 'work',
      shares: 1244,
    ),
  ];

  static final articles = <Article>[
    Article(
      id: 'a1',
      source: 'Reuters',
      title: 'Storm system moves east across the Plains',
      url: 'https://example.com/1',
      publishedAt: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    Article(
      id: 'a2',
      source: 'Benzinga',
      title: 'Fed minutes point to a slower pace of cuts',
      url: 'https://example.com/2',
      publishedAt: DateTime.now().subtract(const Duration(minutes: 52)),
    ),
  ];

  static const tickers = <Ticker>[
    Ticker('SPY', 0.42),
    Ticker('QQQ', 0.61),
    Ticker('BTC', -1.84),
  ];
}
