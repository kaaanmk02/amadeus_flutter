import 'package:flutter/material.dart';
import '../../data/model/kurisu_expression.dart';
import '../theme/app_theme.dart';
import '../widgets/kurisu_avatar.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppTheme.bgDeep, body: SafeArea(child: Stack(children: [
    Positioned.fill(child: CustomPaint(painter: _IntroGrid())),
    Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 12), const Text('FUTURE GADGET LABORATORY', style: TextStyle(color: Color(0xFFB66B70), fontSize: 9, letterSpacing: 3)),
      const SizedBox(height: 8), const Text('AMΔDEUS', style: TextStyle(color: Color(0xFFE9E0DC), fontSize: 38, fontWeight: FontWeight.w300, letterSpacing: 8)),
      const Text('DIGITAL HUMAN INTERFACE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 8, letterSpacing: 2)),
      const SizedBox(height: 20), const SizedBox(height: 350, child: KurisuAvatar(expression: KurisuExpression.normal, size: 205)),
      const Text('“El Psy Kongroo.”', style: TextStyle(color: Color(0xFFC58B8D), fontSize: 14, fontStyle: FontStyle.italic)),
      const SizedBox(height: 26),
      SizedBox(width: 220, height: 48, child: OutlinedButton(onPressed: onStart, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE6C7C2), side: const BorderSide(color: Color(0xFF9D555D)), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)), child: const Text('ESTABLISH CONNECTION', style: TextStyle(letterSpacing: 2, fontSize: 11)))),
      const SizedBox(height: 24), const Text('SYSTEM 0.1.1  •  RESTRICTED ACCESS', style: TextStyle(color: Color(0xFF65616A), fontSize: 8, letterSpacing: 1.2)),
    ])),
  ])));
}
class _IntroGrid extends CustomPainter { @override void paint(Canvas c, Size s) { final p = Paint()..color = const Color(0xFF9D555D).withValues(alpha: 20)..strokeWidth = .5; for (double x=0;x<s.width;x+=32) { c.drawLine(Offset(x,0),Offset(x,s.height),p); } for(double y=0;y<s.height;y+=32) { c.drawLine(Offset(0,y),Offset(s.width,y),p); } } @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false; }
