import 'package:flutter/widgets.dart';

enum KurisuExpression {
  normal,
  happy,
  angry,
  sad,
  thinking,
  blush,
  pissed,
}

extension KurisuExpressionAsset on KurisuExpression {
  static const _map = <KurisuExpression, String>{
    KurisuExpression.normal: 'CRS_JLD_40000100.png',
    KurisuExpression.happy: 'CRS_JLD_40000101.png',
    KurisuExpression.angry: 'CRS_JLD_40000200.png',
    KurisuExpression.sad: 'CRS_JLD_40000300.png',
    KurisuExpression.thinking: 'CRS_JLD_40000400.png',
    KurisuExpression.blush: 'CRS_JLD_40000500.png',
    KurisuExpression.pissed: 'CRS_JLD_40000600.png',
  };

  String assetPath() => 'assets/expressions/${_map[this] ?? _map[KurisuExpression.normal]!}';
}
