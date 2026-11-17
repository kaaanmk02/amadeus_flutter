import 'dart:convert';
import 'kurisu_expression.dart';

class AssistantOutput {
  const AssistantOutput({required this.reply, required this.expression, required this.intensity, required this.confidence});
  final String reply;
  final KurisuExpression expression;
  final double intensity;
  final double confidence;

  static AssistantOutput parse(String raw) {
    try {
      final cleaned = raw.trim().replaceFirst(RegExp(r'^```(?:json)?\s*'), '').replaceFirst(RegExp(r'\s*```$'), '');
      dynamic decoded;
      try {
        decoded = jsonDecode(cleaned);
      } on FormatException {
        final start = cleaned.indexOf('{');
        final end = cleaned.lastIndexOf('}');
        if (start >= 0 && end > start) decoded = jsonDecode(cleaned.substring(start, end + 1));
      }
      if (decoded is Map<String, dynamic>) {
        final name = (decoded['emotion'] ?? 'normal').toString().toLowerCase();
        var expression = KurisuExpression.normal;
        for (final candidate in KurisuExpression.values) { if (candidate.name == name) { expression = candidate; break; } }
        return AssistantOutput(
          reply: (decoded['reply'] ?? decoded['text'] ?? raw).toString(),
          expression: expression,
          intensity: ((decoded['intensity'] as num?)?.toDouble() ?? .5).clamp(0, 1).toDouble(),
          confidence: ((decoded['confidence'] as num?)?.toDouble() ?? .5).clamp(0, 1).toDouble(),
        );
      }
    } catch (_) {}
    return AssistantOutput(reply: raw.trim(), expression: KurisuExpression.normal, intensity: .4, confidence: .2);
  }
}
