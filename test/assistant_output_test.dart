import 'package:flutter_test/flutter_test.dart';
import 'package:amadeus/data/model/assistant_output.dart';
import 'package:amadeus/data/model/kurisu_expression.dart';

void main() {
  test('parses structured emotion output and clamps intensity', () {
    final output = AssistantOutput.parse(
      '{"reply":"Merhaba.","emotion":"happy","intensity":1.4,"confidence":0.9}',
    );
    expect(output.reply, 'Merhaba.');
    expect(output.expression, KurisuExpression.happy);
    expect(output.intensity, 1.0);
    expect(output.confidence, 0.9);
  });

  test('falls back safely for plain text model output', () {
    final output = AssistantOutput.parse('Sana yardımcı olabilirim.');
    expect(output.reply, 'Sana yardımcı olabilirim.');
    expect(output.expression, KurisuExpression.normal);
  });
}
