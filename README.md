# Punchline

A daily punchline, markets, and news. Flutter, Android first.

## Run

```bash
flutter pub get
flutter run
```

The shell runs on `lib/data/sample_data.dart`. No backend is needed yet.

## What is here

- `lib/theme/` — tokens and the dark theme. Every visual value lives here.
- `lib/widgets/` — the five cards the whole feed is built from.
- `lib/screens/` — the four tabs.
- `supabase/schema.sql` — database schema.
- `supabase/jokes_import.csv` — 340 jokes, parsed and categorised, ready to
  score and import.
- `docs/design.md` — the design system. Read before changing anything visual.

## Next

1. Score the jokes in the CSV, drop everything below 4.
2. Create the Supabase project and run `schema.sql`.
3. Import the CSV, replace `sample_data.dart` with real repositories.
4. Wire AdMob, then the RSS aggregation function.
