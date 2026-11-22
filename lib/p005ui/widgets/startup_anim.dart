import 'package:flutter/material.dart';

class StartupAnim extends StatefulWidget {
  const StartupAnim({super.key, required this.onReady});
  final VoidCallback onReady;

  @override
  State<StartupAnim> createState() => _StartupAnimState();
}

class _StartupAnimState extends State<StartupAnim> {
  @override
  void initState() {
    super.initState();
    // Anlık olarak hazır, animasyon yok
    widget.onReady();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
