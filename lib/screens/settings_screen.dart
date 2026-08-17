import 'package:flutter/material.dart';
import '../l10n/app_locale.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: T.surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(T.rSheet)),
        ),
        builder: (_) => const SettingsSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final s = S(state.locale);

    return SafeArea(
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: T.s4),
          children: [
            const SizedBox(height: T.s4),
            _label(s('language')),
            for (final l in AppLocale.values)
              _row(
                title: l.nativeName,
                subtitle: l.englishName,
                selected: state.locale == l,
                onTap: () => state.setLocale(l),
              ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(T.s4, T.s2, T.s4, T.s2),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11, letterSpacing: 0.9, color: T.inkMuted)),
      );

  Widget _row({
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      ListTile(
        dense: true,
        title: Text(title,
            style: const TextStyle(fontSize: 15, color: T.ink)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle,
                style: const TextStyle(fontSize: 12, color: T.inkFaint)),
        trailing: selected
            ? const Icon(Icons.check, size: 18, color: T.coral)
            : null,
        onTap: onTap,
      );
}
