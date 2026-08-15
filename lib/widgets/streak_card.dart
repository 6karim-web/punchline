import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class StreakCard extends StatelessWidget {
  final int days;
  const StreakCard({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: T.card,
        border: Border.all(color: T.border, width: 0.5),
        borderRadius: BorderRadius.circular(T.rCard),
      ),
      padding: const EdgeInsets.symmetric(horizontal: T.s4, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_outlined,
              size: 22, color: T.saffron),
          const SizedBox(width: T.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$days days in a row',
                    style: const TextStyle(fontSize: 14, color: T.text)),
                const SizedBox(height: 2),
                Text('Come back tomorrow to keep it',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
