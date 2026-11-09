import 'chat_message.dart';
import 'kurisu_expression.dart';
import 'personality_type.dart';

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
      );
}
