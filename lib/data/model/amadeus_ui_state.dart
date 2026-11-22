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
    this.expressionIntensity = 0.5,
    this.isChatCollapsed = false,
    this.isLocalAiEnabled = false,
    this.divergenceMeter,
    this.isListening = false,
    // ---- Müzik çantası (KurisuMusicPlayer) ----
    this.musicSongs = const <Map<String, dynamic>>[],
    this.isMusicPlaying = false,
    this.currentMusicIndex = 0,
    this.musicVolume = 80.0,
    this.isMobile = false,
    // ---- KURISU VÜCUDU / BİLGİSEL DURUM ----
    this.currentMessage = '',
    this.intensity = 0.7,
  });

  final List<ChatMessage> messages;
  final PersonalityType currentPersonality;
  final double personalityIntensity;
  final bool isThinking;
  final bool isSpeaking;
  final String streamingResponse;
  final KurisuExpression currentExpression;
  final double expressionIntensity;
  final bool isChatCollapsed;
  final bool isLocalAiEnabled;
  final String? divergenceMeter;
  final bool isListening;

  // ---- Müzik çantası (KurisuMusicPlayer) ----
  final List<Map<String, dynamic>> musicSongs;
  final bool isMusicPlaying;
  final int currentMusicIndex;
  final double musicVolume;
  final bool isMobile;

  // ---- KURISU VÜCUDU / BİLGİSEL DURUM ----
  final String currentMessage;
  final double intensity;

  AmadeusUiState copyWith({
    List<ChatMessage>? messages,
    PersonalityType? currentPersonality,
    double? personalityIntensity,
    bool? isThinking,
    bool? isSpeaking,
    String? streamingResponse,
    KurisuExpression? currentExpression,
    double? expressionIntensity,
    bool? isChatCollapsed,
    bool? isLocalAiEnabled,
    String? divergenceMeter,
    bool? isListening,
    List<Map<String, dynamic>>? musicSongs,
    bool? isMusicPlaying,
    int? currentMusicIndex,
    double? musicVolume,
    bool? isMobile,
    String? currentMessage,
    double? intensity,
  }) =>
      AmadeusUiState(
        messages: messages ?? this.messages,
        currentPersonality: currentPersonality ?? this.currentPersonality,
        personalityIntensity: personalityIntensity ?? this.personalityIntensity,
        isThinking: isThinking ?? this.isThinking,
        isSpeaking: isSpeaking ?? this.isSpeaking,
        streamingResponse: streamingResponse ?? this.streamingResponse,
        currentExpression: currentExpression ?? this.currentExpression,
        expressionIntensity: expressionIntensity ?? this.expressionIntensity,
        isChatCollapsed: isChatCollapsed ?? this.isChatCollapsed,
        isLocalAiEnabled: isLocalAiEnabled ?? this.isLocalAiEnabled,
        divergenceMeter: divergenceMeter ?? this.divergenceMeter,
        isListening: isListening ?? this.isListening,
        musicSongs: musicSongs ?? this.musicSongs,
        isMusicPlaying: isMusicPlaying ?? this.isMusicPlaying,
        currentMusicIndex: currentMusicIndex ?? this.currentMusicIndex,
        musicVolume: musicVolume ?? this.musicVolume,
        isMobile: isMobile ?? this.isMobile,
        currentMessage: currentMessage ?? this.currentMessage,
        intensity: intensity ?? this.intensity,
      );
}
