import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// The crease. Dashed while folded, solid saffron once opened.
class DashedLine extends StatelessWidget {
  final bool solid;
  const DashedLine({super.key, this.solid = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 1,
        child: CustomPaint(
          painter: _Painter(
            solid: solid,
            color: solid ? T.saffron.withValues(alpha: 0.35) : T.borderSoft,
          ),
          size: const Size(double.infinity, 1),
        ),
      );
}

class _Painter extends CustomPainter {
  final bool solid;
  final Color color;
  _Painter({required this.solid, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    if (solid) {
      canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
      return;
    }
    const dash = 3.0, gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), p);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_Painter old) => old.solid != solid || old.color != color;
}
