import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'kurisu_expression.dart';

/// `AmadeusEmotionModulationMode` — müzik türüne göre avatar duygu katmanı.
enum AmadeusEmotionModulationMode { none, elevatedEnergy, lowKeyAnalytical }

/// `AmadeusUiState.java` karşılığı: tek örneklemeli (copyWith) UI durumu.
class AmadeusUiState {
  const AmadeusUiState({
    this.messages = const <ChatMessage>[],
    this.currentPersonality = PersonalityType.tsundere,
    this.personalityIntensity = 0.7,
    this.isThinking = false,
    this.isSpeaking = false,
    this.streamingResponse = '',
    this.currentExpression = KurisuExpression.normal,
    this.isChatCollapsed = false,
    this.isLocalAiEnabled = false,
    this.divergenceMeter,
    this.isListening = false,
    this.hapticEnabled = true,
    this.musicGenre = '',
    this.musicModulation = AmadeusEmotionModulationMode.none,
  });

  final List<ChatMessage> messages;
  final PersonalityType currentPersonality;
  final double personalityIntensity;
  final bool isThinking;
  final bool isSpeaking;
  final String streamingResponse;
  final KurisuExpression currentExpression;
  final bool isChatCollapsed;
  final bool isLocalAiEnabled;
  final String? divergenceMeter;
  final bool isListening;
  final bool hapticEnabled;
  final String musicGenre;
  final AmadeusEmotionModulationMode musicModulation;

  AmadeusUiState copyWith({
    List<ChatMessage>? messages,
    PersonalityType? currentPersonality,
    double? personalityIntensity,
    bool? isThinking,
    bool? isSpeaking,
    String? streamingResponse,
    KurisuExpression? currentExpression,
    bool? isChatCollapsed,
    bool? isLocalAiEnabled,
    String? divergenceMeter,
    bool? isListening,
    bool? hapticEnabled,
    String? musicGenre,
    AmadeusEmotionModulationMode? musicModulation,
  }) =>
      AmadeusUiState(
        messages: messages ?? this.messages,
        currentPersonality: currentPersonality ?? this.currentPersonality,
        personalityIntensity: personalityIntensity ?? this.personalityIntensity,
        isThinking: isThinking ?? this.isThinking,
        isSpeaking: isSpeaking ?? this.isSpeaking,
        streamingResponse: streamingResponse ?? this.streamingResponse,
        currentExpression: currentExpression ?? this.currentExpression,
        isChatCollapsed: isChatCollapsed ?? this.isChatCollapsed,
        isLocalAiEnabled: isLocalAiEnabled ?? this.isLocalAiEnabled,
        divergenceMeter: divergenceMeter ?? this.divergenceMeter,
        isListening: isListening ?? this.isListening,
        hapticEnabled: hapticEnabled ?? this.hapticEnabled,
        musicGenre: musicGenre ?? this.musicGenre,
        musicModulation: musicModulation ?? this.musicModulation,
      );
}
