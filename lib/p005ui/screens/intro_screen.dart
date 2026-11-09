import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Giriş ekranı. `MainActivity` içindeki `IntroScreen` composable'ı karşılığı.
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AMADEUS',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGreen,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'El Psy Kongroo.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: onStart,
                child: const Text('Başlat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
