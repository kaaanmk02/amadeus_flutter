import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../data/model/kurisu_expression.dart';

class KurisuAvatar extends StatelessWidget {
  final double size;
  final String asset;
  final double intensityScale;
  final bool isSpeaking;
  final bool isThinking;
  final double intensity;
  final KurisuExpression? expression;

  const KurisuAvatar({
    super.key,
    required this.size,
    this.asset = 'assets/frames_fullbody/CRS_kurisu_fullbody_001.png',
    this.intensityScale = 1.0,
    this.isSpeaking = false,
    this.isThinking = false,
    this.intensity = 1.0,
    this.expression,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Full body Kurisu with squinted eyes
        Image.asset(
          asset,
          fit: BoxFit.contain,
          height: size * 0.95,
          width: size * 0.6,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.person, size: 120, color: AppTheme.textSecondary),
          ),
        ),
        // Glow effect
        Container(
          width: size * 1.0,
          height: size * 0.7,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentAmber.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 20,
              ),
              BoxShadow(
                color: AppTheme.accentRed.withValues(alpha: 0.08),
                blurRadius: 30,
                spreadRadius: 15,
              ),
            ],
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        if (isThinking)
          Positioned(top: 10, right: 10, child: _thinkingDots())
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _thinkingDots() =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.accentAmber.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('···', style: TextStyle(color: AppTheme.accentAmber, fontSize: 16, height: 1.2)),
      );
}
