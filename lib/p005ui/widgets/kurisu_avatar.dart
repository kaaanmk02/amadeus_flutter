import 'package:flutter/material.dart';

import '../../data/model/kurisu_expression.dart';
import '../theme/app_theme.dart';

/// Kurisu avatarı. `MainActivity` içindeki Compose `KurisuAvatar` karşılığı.
/// İfadeye göre farklı renk/parlaklık kombinasyonu kullanır.
class KurisuAvatar extends StatelessWidget {
  const KurisuAvatar({super.key, required this.expression, this.size = 160});

  final KurisuExpression expression;
  final double size;

  Color get _glowColor {
    switch (expression) {
      case KurisuExpression.angry:
        return AppTheme.accentRed;
      case KurisuExpression.happy:
      case KurisuExpression.blush:
        return AppTheme.accentGreen;
      case KurisuExpression.sad:
        return AppTheme.accentBlue;
      case KurisuExpression.thinking:
      case KurisuExpression.pissed:
        return AppTheme.accentAmber;
      case KurisuExpression.normal:
        return AppTheme.accentPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _glowColor.withValues(alpha: 0.35),
            AppTheme.bgDeep,
          ],
        ),
        border: Border.all(color: _glowColor, width: 2),
      ),
      child: Icon(
        Icons.face,
        size: size * 0.5,
        color: _glowColor,
      ),
    );
  }
}
