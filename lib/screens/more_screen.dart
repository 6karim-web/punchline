import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _items = <(IconData, String)>[
    (Icons.menu_book_outlined, 'Library'),
    (Icons.favorite_border, 'Saved'),
    (Icons.tune, 'Your interests'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(T.s3),
      children: [
        for (final (icon, label) in _items)
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 2),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: T.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 19, color: T.textMuted),
                  const SizedBox(width: T.s3),
                  Text(label,
                      style: const TextStyle(fontSize: 15, color: T.text)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
