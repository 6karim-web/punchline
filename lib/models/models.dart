class Joke {
  final String id;
  final String title;
  final String setup;
  final String punchline;
  final String category;
  final bool adult;

  const Joke({
    required this.id,
    required this.title,
    required this.setup,
    required this.punchline,
    required this.category,
    this.adult = false,
  });

  /// What goes to WhatsApp. The card is the brand; the text carries it.
  String get shareText => '$setup\n\n$punchline';
}
