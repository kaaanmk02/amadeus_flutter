import 'kurisu_expression.dart';

/// Exhaustive catalogue for the original Amadeus sprite set.
/// 174 PNGs = 6 sprite families × 7–12 poses × 3 animation frames.
/// Pose labels are kept as source IDs because their semantic meaning is not documented.
class KurisuExpressionAsset {
  const KurisuExpressionAsset._();

  static const Map<String, List<List<String>>> _families = {
    'JLD': [
      ['assets/expressions/CRS_JLD_40000100.png', 'assets/expressions/CRS_JLD_40000101.png', 'assets/expressions/CRS_JLD_40000102.png'], // pose 01
      ['assets/expressions/CRS_JLD_40000200.png', 'assets/expressions/CRS_JLD_40000201.png', 'assets/expressions/CRS_JLD_40000202.png'], // pose 02
      ['assets/expressions/CRS_JLD_40000300.png', 'assets/expressions/CRS_JLD_40000301.png', 'assets/expressions/CRS_JLD_40000302.png'], // pose 03
      ['assets/expressions/CRS_JLD_40000400.png', 'assets/expressions/CRS_JLD_40000401.png', 'assets/expressions/CRS_JLD_40000402.png'], // pose 04
      ['assets/expressions/CRS_JLD_40000500.png', 'assets/expressions/CRS_JLD_40000501.png', 'assets/expressions/CRS_JLD_40000502.png'], // pose 05
      ['assets/expressions/CRS_JLD_40000600.png', 'assets/expressions/CRS_JLD_40000601.png', 'assets/expressions/CRS_JLD_40000602.png'], // pose 06
      ['assets/expressions/CRS_JLD_40000700.png', 'assets/expressions/CRS_JLD_40000701.png', 'assets/expressions/CRS_JLD_40000702.png'], // pose 07
      ['assets/expressions/CRS_JLD_40000800.png', 'assets/expressions/CRS_JLD_40000801.png', 'assets/expressions/CRS_JLD_40000802.png'], // pose 08
      ['assets/expressions/CRS_JLD_40000900.png', 'assets/expressions/CRS_JLD_40000901.png', 'assets/expressions/CRS_JLD_40000902.png'], // pose 09
      ['assets/expressions/CRS_JLD_40000a00.png', 'assets/expressions/CRS_JLD_40000a01.png', 'assets/expressions/CRS_JLD_40000a02.png'], // pose 0a
      ['assets/expressions/CRS_JLD_40000b00.png', 'assets/expressions/CRS_JLD_40000b01.png', 'assets/expressions/CRS_JLD_40000b02.png'], // pose 0b
      ['assets/expressions/CRS_JLD_40000c00.png', 'assets/expressions/CRS_JLD_40000c01.png', 'assets/expressions/CRS_JLD_40000c02.png'], // pose 0c
    ],
    'JLE': [
      ['assets/expressions/CRS_JLE_40000100.png', 'assets/expressions/CRS_JLE_40000101.png', 'assets/expressions/CRS_JLE_40000102.png'], // pose 01
      ['assets/expressions/CRS_JLE_40000200.png', 'assets/expressions/CRS_JLE_40000201.png', 'assets/expressions/CRS_JLE_40000202.png'], // pose 02
      ['assets/expressions/CRS_JLE_40000300.png', 'assets/expressions/CRS_JLE_40000301.png', 'assets/expressions/CRS_JLE_40000302.png'], // pose 03
      ['assets/expressions/CRS_JLE_40000400.png', 'assets/expressions/CRS_JLE_40000401.png', 'assets/expressions/CRS_JLE_40000402.png'], // pose 04
      ['assets/expressions/CRS_JLE_40000500.png', 'assets/expressions/CRS_JLE_40000501.png', 'assets/expressions/CRS_JLE_40000502.png'], // pose 05
      ['assets/expressions/CRS_JLE_40000600.png', 'assets/expressions/CRS_JLE_40000601.png', 'assets/expressions/CRS_JLE_40000602.png'], // pose 06
      ['assets/expressions/CRS_JLE_40000700.png', 'assets/expressions/CRS_JLE_40000701.png', 'assets/expressions/CRS_JLE_40000702.png'], // pose 07
    ],
    'JLF': [
      ['assets/expressions/CRS_JLF_00000001.png'], // pose full
    ],
    'JMD': [
      ['assets/expressions/CRS_JMD_40000100.png', 'assets/expressions/CRS_JMD_40000101.png', 'assets/expressions/CRS_JMD_40000102.png'], // pose 01
      ['assets/expressions/CRS_JMD_40000200.png', 'assets/expressions/CRS_JMD_40000201.png', 'assets/expressions/CRS_JMD_40000202.png'], // pose 02
      ['assets/expressions/CRS_JMD_40000300.png', 'assets/expressions/CRS_JMD_40000301.png', 'assets/expressions/CRS_JMD_40000302.png'], // pose 03
      ['assets/expressions/CRS_JMD_40000400.png', 'assets/expressions/CRS_JMD_40000401.png', 'assets/expressions/CRS_JMD_40000402.png'], // pose 04
      ['assets/expressions/CRS_JMD_40000500.png', 'assets/expressions/CRS_JMD_40000501.png', 'assets/expressions/CRS_JMD_40000502.png'], // pose 05
      ['assets/expressions/CRS_JMD_40000600.png', 'assets/expressions/CRS_JMD_40000601.png', 'assets/expressions/CRS_JMD_40000602.png'], // pose 06
      ['assets/expressions/CRS_JMD_40000700.png', 'assets/expressions/CRS_JMD_40000701.png', 'assets/expressions/CRS_JMD_40000702.png'], // pose 07
      ['assets/expressions/CRS_JMD_40000800.png', 'assets/expressions/CRS_JMD_40000801.png', 'assets/expressions/CRS_JMD_40000802.png'], // pose 08
      ['assets/expressions/CRS_JMD_40000900.png', 'assets/expressions/CRS_JMD_40000901.png', 'assets/expressions/CRS_JMD_40000902.png'], // pose 09
      ['assets/expressions/CRS_JMD_40000a00.png', 'assets/expressions/CRS_JMD_40000a01.png', 'assets/expressions/CRS_JMD_40000a02.png'], // pose 0a
      ['assets/expressions/CRS_JMD_40000b00.png', 'assets/expressions/CRS_JMD_40000b01.png', 'assets/expressions/CRS_JMD_40000b02.png'], // pose 0b
      ['assets/expressions/CRS_JMD_40000c00.png', 'assets/expressions/CRS_JMD_40000c01.png', 'assets/expressions/CRS_JMD_40000c02.png'], // pose 0c
    ],
    'JME': [
      ['assets/expressions/CRS_JME_40000100.png', 'assets/expressions/CRS_JME_40000101.png', 'assets/expressions/CRS_JME_40000102.png'], // pose 01
      ['assets/expressions/CRS_JME_40000200.png', 'assets/expressions/CRS_JME_40000201.png', 'assets/expressions/CRS_JME_40000202.png'], // pose 02
      ['assets/expressions/CRS_JME_40000300.png', 'assets/expressions/CRS_JME_40000301.png', 'assets/expressions/CRS_JME_40000302.png'], // pose 03
      ['assets/expressions/CRS_JME_40000400.png', 'assets/expressions/CRS_JME_40000401.png', 'assets/expressions/CRS_JME_40000402.png'], // pose 04
      ['assets/expressions/CRS_JME_40000500.png', 'assets/expressions/CRS_JME_40000501.png', 'assets/expressions/CRS_JME_40000502.png'], // pose 05
      ['assets/expressions/CRS_JME_40000600.png', 'assets/expressions/CRS_JME_40000601.png', 'assets/expressions/CRS_JME_40000602.png'], // pose 06
      ['assets/expressions/CRS_JME_40000700.png', 'assets/expressions/CRS_JME_40000701.png', 'assets/expressions/CRS_JME_40000702.png'], // pose 07
    ],
    'JMF': [
      ['assets/expressions/CRS_JMF_00000001.png'], // pose full
    ],
    'JSD': [
      ['assets/expressions/CRS_JSD_40000100.png', 'assets/expressions/CRS_JSD_40000101.png', 'assets/expressions/CRS_JSD_40000102.png'], // pose 01
      ['assets/expressions/CRS_JSD_40000200.png', 'assets/expressions/CRS_JSD_40000201.png', 'assets/expressions/CRS_JSD_40000202.png'], // pose 02
      ['assets/expressions/CRS_JSD_40000300.png', 'assets/expressions/CRS_JSD_40000301.png', 'assets/expressions/CRS_JSD_40000302.png'], // pose 03
      ['assets/expressions/CRS_JSD_40000400.png', 'assets/expressions/CRS_JSD_40000401.png', 'assets/expressions/CRS_JSD_40000402.png'], // pose 04
      ['assets/expressions/CRS_JSD_40000500.png', 'assets/expressions/CRS_JSD_40000501.png', 'assets/expressions/CRS_JSD_40000502.png'], // pose 05
      ['assets/expressions/CRS_JSD_40000600.png', 'assets/expressions/CRS_JSD_40000601.png', 'assets/expressions/CRS_JSD_40000602.png'], // pose 06
      ['assets/expressions/CRS_JSD_40000700.png', 'assets/expressions/CRS_JSD_40000701.png', 'assets/expressions/CRS_JSD_40000702.png'], // pose 07
      ['assets/expressions/CRS_JSD_40000800.png', 'assets/expressions/CRS_JSD_40000801.png', 'assets/expressions/CRS_JSD_40000802.png'], // pose 08
      ['assets/expressions/CRS_JSD_40000900.png', 'assets/expressions/CRS_JSD_40000901.png', 'assets/expressions/CRS_JSD_40000902.png'], // pose 09
      ['assets/expressions/CRS_JSD_40000a00.png', 'assets/expressions/CRS_JSD_40000a01.png', 'assets/expressions/CRS_JSD_40000a02.png'], // pose 0a
      ['assets/expressions/CRS_JSD_40000b00.png', 'assets/expressions/CRS_JSD_40000b01.png', 'assets/expressions/CRS_JSD_40000b02.png'], // pose 0b
      ['assets/expressions/CRS_JSD_40000c00.png', 'assets/expressions/CRS_JSD_40000c01.png', 'assets/expressions/CRS_JSD_40000c02.png'], // pose 0c
    ],
    'JSE': [
      ['assets/expressions/CRS_JSE_40000100.png', 'assets/expressions/CRS_JSE_40000101.png', 'assets/expressions/CRS_JSE_40000102.png'], // pose 01
      ['assets/expressions/CRS_JSE_40000200.png', 'assets/expressions/CRS_JSE_40000201.png', 'assets/expressions/CRS_JSE_40000202.png'], // pose 02
      ['assets/expressions/CRS_JSE_40000300.png', 'assets/expressions/CRS_JSE_40000301.png', 'assets/expressions/CRS_JSE_40000302.png'], // pose 03
      ['assets/expressions/CRS_JSE_40000400.png', 'assets/expressions/CRS_JSE_40000401.png', 'assets/expressions/CRS_JSE_40000402.png'], // pose 04
      ['assets/expressions/CRS_JSE_40000500.png', 'assets/expressions/CRS_JSE_40000501.png', 'assets/expressions/CRS_JSE_40000502.png'], // pose 05
      ['assets/expressions/CRS_JSE_40000600.png', 'assets/expressions/CRS_JSE_40000601.png', 'assets/expressions/CRS_JSE_40000602.png'], // pose 06
      ['assets/expressions/CRS_JSE_40000700.png', 'assets/expressions/CRS_JSE_40000701.png', 'assets/expressions/CRS_JSE_40000702.png'], // pose 07
    ],
    'JSF': [
      ['assets/expressions/CRS_JSF_00000001.png'], // pose full
    ],
  };

  static const Map<KurisuExpression, String> familyForExpression = {
    KurisuExpression.normal: 'JMD',
    KurisuExpression.happy: 'JLD',
    KurisuExpression.angry: 'JLE',
    KurisuExpression.sad: 'JSD',
    KurisuExpression.thinking: 'JSE',
    KurisuExpression.blush: 'JME',
    KurisuExpression.pissed: 'JLE',
  };

  static List<List<String>> posesFor(KurisuExpression expression) {
    final family = familyForExpression[expression]!;
    final poses = List<List<String>>.from(_families[family]!);
    final special = switch (family) {
      'JLD' => 'JLF',
      'JME' => 'JMF',
      'JSE' => 'JSF',
      _ => null,
    };
    if (special != null) poses.addAll(_families[special]!);
    return poses;
  }

  static List<String> allAssets = [
    for (final family in _families.values)
      for (final pose in family)
        ...pose,
  ];

  static int get totalAssetCount => allAssets.length;
  static int get totalPoseCount =>
      _families.values.fold<int>(0, (n, poses) => n + poses.length);
}
