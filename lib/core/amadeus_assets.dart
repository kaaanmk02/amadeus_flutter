import '../../core/app_config.dart';

class AmadeusAssetPaths {
  static const expressionCount = 174;
  static const expressionPrefix = 'CRS_';
  static const expressionBase = 'assets/expressions';
  static const voiceBase = 'assets/voices';
}

class AmadeusAssetLookup {
  static String expression(String baseName) =>
      '${AmadeusAssetPaths.expressionBase}/$baseName.png';
  static String expressionOrDefault(String? baseName) =>
      expression(baseName ?? 'CRS_JLD_40000100');
  static String voice(String fileName) =>
      '${AmadeusAssetPaths.voiceBase}/$fileName';
}
