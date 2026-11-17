/// Kişilik + ruh hâlinin birleşimi. `PersonalityState.java` ile aynı alanlar.
library;

import 'mood_state.dart';
import 'personality_type.dart';

class PersonalityState {
  const PersonalityState({
    required this.personality,
    required this.mood,
    required this.intensity,
    this.trigger,
    this.duration,
  });

  final PersonalityType personality;
  final MoodState mood;
  final double intensity; // 0.0 - 1.0
  final String? trigger;
  final Duration? duration;

  PersonalityState copyWith({
    PersonalityType? personality,
    MoodState? mood,
    double? intensity,
    String? trigger,
  }) =>
      PersonalityState(
        personality: personality ?? this.personality,
        mood: mood ?? this.mood,
        intensity: intensity ?? this.intensity,
        trigger: trigger ?? this.trigger,
        duration: duration,
      );
}
