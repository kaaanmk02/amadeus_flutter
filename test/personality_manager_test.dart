import 'package:flutter_test/flutter_test.dart';
import 'package:amadeus/domain/personality_manager.dart';
import 'package:amadeus/data/model/personality_type.dart';

void main() {
  const manager = PersonalityManager();

  test('personality selection changes the style contract', () {
    final tsundere = manager.getSystemPrompt(PersonalityType.tsundere, 0.7);
    final kuudere = manager.getSystemPrompt(PersonalityType.kuudere, 0.7);
    expect(tsundere, contains('AKTİF ÜSLUP: tsundere'));
    expect(kuudere, contains('AKTİF ÜSLUP: kuudere'));
    expect(tsundere, isNot(kuudere));
  });

  test('custom prompt is appended without replacing the character contract', () {
    final prompt = manager.getSystemPrompt(
      PersonalityType.tsundere,
      0.5,
      customPrompt: 'Daha kısa cevap ver.',
    );
    expect(prompt, contains('AMADEUS CORE / CHARACTER CONTRACT'));
    expect(prompt, contains('Daha kısa cevap ver.'));
    expect(prompt, contains('ÇIKTI PROTOKOLÜ'));
  });
}
