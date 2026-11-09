import 'package:flutter/material.dart';

import '../../data/model/kurisu_expression.dart';
import '../theme/app_theme.dart';
import '../widgets/kurisu_avatar.dart';

/// Arama/karşılama ekranı. `CallingScreen` composable'ı karşılığı.
class CallingScreen extends StatelessWidget {
  const CallingScreen({
    super.key,
    required this.onConnected,
    required this.expression,
  });

  final VoidCallback onConnected;
  final KurisuExpression expression;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KurisuAvatar(expression: expression, size: 200),
              const SizedBox(height: 32),
              const Text(
                'AMADEUS bağlantısı kuruluyor...',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onConnected,
                child: const Text('Bağlan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
