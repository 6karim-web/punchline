import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';

class Loading extends StatelessWidget {
  final String label;
  const Loading({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: T.s6),
        child: Column(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: T.saffron),
            ),
            const SizedBox(height: T.s3),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}

/// Errors say what happened and what to do. No apology, no exception string.
class Failed extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const Failed({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: T.s6),
        child: Column(
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: T.text)),
            const SizedBox(height: T.s3),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: T.text,
                side: const BorderSide(color: T.borderSoft, width: 0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(T.rControl)),
              ),
              child: Text(S(AppState.instance.locale)('tryAgain')),
            ),
          ],
        ),
      );
}
