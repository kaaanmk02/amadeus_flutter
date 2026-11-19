import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../data/model/kurisu_expression.dart';

class KurisuAvatar extends StatelessWidget {
  final double size;
  final String asset;
  final double intensityScale;
  final KurisuExpression expression;
  final bool isSpeaking;
  final bool isThinking;
  final double intensity;

  const KurisuAvatar({
    super.key,
    required this.size,
    this.asset = 'assets/expressions/CRS_JLD_40000100.png',
    this.intensityScale = 1.0,
    required this.expression,
    this.isSpeaking = false,
    this.isThinking = false,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: intensityScale,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 10,
            child: Container(
              width: size * .76,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: AppTheme.accentRed.a * .12),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentRed.withValues(alpha: AppTheme.accentRed.a * .16),
                    blurRadius: 28,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 130),
            child: Image.asset(
              asset,
              key: ValueKey(asset),
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 72, color: AppTheme.textSecondary),
              ),
            ),
          ),
          isThinking
              ? Positioned(top: 8, right: 18, child: _thinkingDots())
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _thinkingDots() =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accentAmber.withValues(alpha: ((AppTheme.accentAmber.a * .5).round().clamp(0, 255)).toDouble()),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('···', style: TextStyle(color: AppTheme.accentAmber, fontSize: 20, height: 1)),
      );
}
