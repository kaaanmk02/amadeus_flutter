import 'package:flutter/material.dart';
import '../../data/model/kurisu_expression.dart';
import '../theme/app_theme.dart';
import '../widgets/kurisu_avatar.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _IntroGrid()),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'AMADEUS',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 5,
                    fontFamily: 'monospace',
                  ),
                ),
                const Text(
                  'DIGITAL HUMAN INTERFACE',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 9,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Steins;Gate 0 — Future Gadget Laboratory',
                  style: TextStyle(
                    color: AppTheme.accentAmber,
                    fontSize: 8,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const KurisuAvatar(expression: KurisuExpression.normal, size: 190, isSpeaking: false, isThinking: false),
                const SizedBox(height: 10),
                const Text(
                  '“El Psy Kongroo.”',
                  style: TextStyle(
                    color: AppTheme.accentPurple,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 240,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'ESTABLISH CONNECTION',
                      style: TextStyle(
                        letterSpacing: 2.5,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'v2.0.0 • STM 3.47.9 • Flutter 3.47.9',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 8,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroGrid extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = const Color(0xFF9D555D).withValues(alpha: 18)
      ..strokeWidth = .5;
    for (double x = 0; x < s.width; x += 48) {
      c.drawLine(Offset(x, 0), Offset(x, s.height), p);
    }
    for (double y = 0; y < s.height; y += 48) {
      c.drawLine(Offset(0, y), Offset(s.width, y), p);
    }
    for (int i = 0; i < 12; i++) {
      final y = (i * 45).toDouble();
      final scan = Paint()
        ..color = const Color(0xFFB66B70).withValues(alpha: 8 + i * 3)
        ..strokeWidth = 1;
      c.drawLine(Offset(0, y), Offset(s.width, y), scan);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
