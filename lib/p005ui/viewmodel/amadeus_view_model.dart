import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/app_config.dart';
import '../../core/exceptions.dart';
import '../../data/ai/local_llm_manager.dart';
import '../../data/audio/sound_manager.dart';
import '../../data/audio/speech_manager.dart';
import '../../data/ai/llama_gguf_service.dart';
import '../../data/model/amadeus_ui_state.dart';
import '../../data/model/chat_message.dart';
import '../../data/model/kurisu_expression.dart';
import '../../data/model/personality_type.dart';
import '../../data/repository/amadeus_repository.dart';
import '../../services/rust_emotion_interpreter.dart';

/// `AmadeusViewModel.java` karşılığı.
///
/// Kullanıcı etkileşimlerini alır, repository'den akışı dinler ve
/// `AmadeusUiState`'i günceller. `ChangeNotifier` ile Compose `StateFlow`
/// davranışı taklit edilir.
class AmadeusViewModel extends ChangeNotifier {
  AmadeusViewModel({
    required this.repository,
    required this.soundManager,
    required this.speechManager,
    required this.localLlmManager,
    required this.onSpeak,
    this.onExpressionChanged,
  });

  final AmadeusRepository repository;
  final SoundManager soundManager;
  final SpeechManager speechManager;
  final LocalLlmManager localLlmManager;

  /// Asistan cevabını seslendirmek için UI katmanına verilen callback.
  final void Function(String text) onSpeak;

  /// İfade değişiminde çağrılır (Android: `updateExpression`).
  final void Function(KurisuExpression expression)? onExpressionChanged;

  AmadeusUiState _uiState = const AmadeusUiState();
  AmadeusUiState get uiState => _uiState;

  StreamSubscription<String>? _streamSubscription;

  // ------------------------------------------------------------------
  // API erişimcileri (getApiUrl / getModelName / getApiKey)
  // ------------------------------------------------------------------
  String get apiUrl => repository.settings.getApiUrl();
  String get modelName => repository.settings.getModelName();
  String get apiKey => repository.settings.getApiKey();
  String get customSystemPrompt => repository.settings.getCustomSystemPrompt();
  Future<void> setCustomSystemPrompt(String prompt) =>
      repository.settings.setCustomSystemPrompt(prompt);
  int get contextWindow => repository.settings.getContextWindow();
  Future<void> setContextWindow(int value) =>
      repository.settings.setContextWindow(value);

  // ------------------------------------------------------------------
  // Bağlantı
  // ------------------------------------------------------------------
  void onConnected() {
    updateDivergence();
  }

  // ------------------------------------------------------------------
  // Ayarlar
  // ------------------------------------------------------------------
  void saveSettings(String url, String model, String key) {
    repository.settings.setApiUrl(url);
    repository.settings.setModelName(model);
    repository.settings.setApiKey(key);
  }

  void setPersonality(PersonalityType type) {
    _updateUiState(currentPersonality: type);
  }

  void setIntensity(double intensity) {
    _updateUiState(personalityIntensity: intensity);
  }

  bool get autoSpeak => repository.settings.getAutoSpeak();
  bool get hapticEnabled => repository.settings.getHapticEnabled();
  Future<void> setAutoSpeak(bool value) async {
    await repository.settings.setAutoSpeak(value);
  }

  Future<void> setHaptic(bool value) async =>
      await repository.settings.setHapticEnabled(value);

  String get musicGenre => repository.settings.getMusicGenre();
  Future<void> setMusicGenre(String genre) async =>
      await repository.settings.setMusicGenre(genre);

  Future<void> playMusicForGenre(String genre) async {
    if (genre == 'amadeus_ost') return;
    await soundManager.stopAllAudio();
  }

  Future<void> playAmadeusTrack(String title) async {
    final clean = title.replaceAll('"', "'");
    final asset = 'assets/audio/amadeus_ost/$clean.wav';
    await soundManager.stopAllAudio();
    await soundManager.play(asset, loop: true);
  }

  String get ttsProvider => repository.settings.getTtsProvider();
  Future<void> setTtsProvider(String provider) async {
    await repository.settings.setTtsProvider(provider);
  }

  String get localModelName => AppConfig.defaultLocalModelName;
  String? get localModelPath => repository.settings.getLocalModelPath();
  Future<void> setLocalModelPath(String? path) async =>
      await repository.settings.setLocalModelPath(path);

  Future<String?> generateWithLocalGguf(String prompt) async {
    final path = repository.settings.getLocalModelPath();
    if (path == null) return null;
    try {
      final service = LlamaGgufService.instance;
      final loaded = await service.loadModel();
      if (!loaded) return null;
      final stream = service.generateStream(prompt);
      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.writeln(chunk);
      }
      return buffer.toString().trim().isEmpty ? null : buffer.toString().trim();
    } on Exception catch (_) {
      return null;
    }
  }

  void toggleLocalAi(bool enabled) {
    _updateUiState(isLocalAiEnabled: enabled);
    if (enabled) {
      localLlmManager.initialize('gemma-2b-it-gpu-int4.bin');
    }
  }

  // ------------------------------------------------------------------
  // Sohbet
  // ------------------------------------------------------------------
  void clearChat() {
    repository.clearHistory();
    _updateUiState(
      messages: const <ChatMessage>[],
      streamingResponse: '',
    );
    soundManager.play('ok');
  }

  void toggleChatCollapse() {
    _updateUiState(isChatCollapsed: !_uiState.isChatCollapsed);
  }

  void stopAudio() {
    soundManager.stopAllAudio();
  }

  void toggleListening() {
    if (_uiState.isListening) {
      speechManager.stopListening();
      _updateUiState(isListening: false);
      return;
    }
    speechManager.startListening((text) {
      sendMessage(text, null);
    }).then((ok) {
      if (ok) _updateUiState(isListening: true);
    });
  }

  /// Kullanıcı mesajı gönderir. `AmadeusViewModel$sendMessage$1` karşılığı.
  Future<void> sendMessage(String text, String? imageBase64) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && imageBase64 == null) return;

    if (imageBase64 == null && handleSystemCommands(trimmed)) return;

    final userMessage = ChatMessage(
      role: 'user',
      content: trimmed,
      imageBase64: imageBase64,
      imageList: imageBase64 != null ? [imageBase64] : null,
    );

    _updateUiState(
      messages: <ChatMessage>[..._uiState.messages, userMessage],
      isThinking: true,
      streamingResponse: '',
    );

    try {
      await for (final chunk in repository.sendMessageStream(
        trimmed,
        type: _uiState.currentPersonality,
        intensity: _uiState.personalityIntensity,
        imageBase64: imageBase64,
      )) {
        _updateUiState(streamingResponse: _uiState.streamingResponse + chunk);
        _applyEmotionToState(_uiState.streamingResponse);
      }
    } on ApiException catch (e) {
      _updateUiState(streamingResponse: e.message, isThinking: false);
      final fallback = await localLlmManager.generate(trimmed, fallbackPrompt: systemPrompt);
      if (fallback != null && fallback.isNotEmpty) {
        _updateUiState(streamingResponse: fallback, isThinking: false);
        _finalizeAssistantMessage(fallback);
        return;
      }
      _showNotification('Bağlantı Hatası', e.message);
      return;
    } on Exception catch (e) {
      _updateUiState(streamingResponse: 'Hata: $e', isThinking: false);
      _showNotification('Hata', '$e');
      return;
    }

    if (_uiState.streamingResponse.isNotEmpty) {
      repository.addMessageToHistory(ChatMessage(
        role: 'assistant',
        content: _uiState.streamingResponse,
      ));
      if (repository.settings.getAutoSpeak()) {
        onSpeak(_uiState.streamingResponse);
      }
      _finalizeAssistantMessage(_uiState.streamingResponse);
      _showNotification('Kurisu', _uiState.streamingResponse.substring(0, 120));
    } else {
      _updateUiState(isThinking: false);
    }
  }

  /// `sendMessageDirectly` — kullanıcı mesajı eklemeden salt asistan cevabı.
  Future<void> sendMessageDirectly(String response) async {
    repository.sendMessageDirectly(response);
    _updateUiState(
      messages: <ChatMessage>[
        ..._uiState.messages,
        ChatMessage(role: 'assistant', content: response),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Sistem komutları
  // ------------------------------------------------------------------
  /// `handleSystemCommands` — sohbet akışını kesmeden komutları işler.
  /// Komut tanınırsa `true` döner (akışa girilmez).
  bool handleSystemCommands(String text) {
    final lower = text.toLowerCase();
    if (lower == '/start') {
      sendMessageDirectly('Günaydın. Okabe mi? Yoksa başka biri mi?');
      return true;
    }
    if (lower == '/reset') {
      clearChat();
      return true;
    }
    return false;
  }

  // ------------------------------------------------------------------
  // Emotion + Expression + Avatar state
  // ------------------------------------------------------------------
  /// `_applyEmotionToState` — RustResponse benzeri metinden duygu yoğunluğu çıkarır,
  /// avatar ifadesini günceller, haptic tetikler ve son mesaja duygu verisini yazar.
  void _applyEmotionToState(String text) {
    final snapshot = EmotionInterpreter.classifyWithIntensity(
      RustResponse(text: text, toneScore: null, keywords: const []),
    );
    final nextExpression = EmotionInterpreter.avatarExpressionFor(snapshot.emotion);

    if (_uiState.hapticEnabled) {
      EmotionInterpreter.triggerHaptic(snapshot.emotion, snapshot.intensity);
    }

    if (nextExpression != _uiState.currentExpression) {
      _updateUiState(currentExpression: nextExpression);
      onExpressionChanged?.call(nextExpression);
    }

    if (_uiState.messages.isNotEmpty) {
      final last = _uiState.messages.last;
      final updated = ChatMessage(
        role: last.role,
        content: last.content,
        imageBase64: last.imageBase64,
        imageList: last.imageList,
        timestamp: last.timestamp,
        emotion: snapshot.emotion.name,
        emotionIntensity: snapshot.intensity,
      );
      final replaced = List<ChatMessage>.from(_uiState.messages);
      replaced[replaced.length - 1] = updated;
      _updateUiState(messages: replaced);
    }
  }

  /// `updateDivergence` — 0.00000000 - 1.10000000 arası rastgele değer üretir.
  void updateDivergence() {
    _updateUiState(divergenceMeter: repository.nextDivergence());
  }

  // ------------------------------------------------------------------
  // Yardımcılar
  // ------------------------------------------------------------------
  void _updateUiState({
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
  }) {
    _uiState = _uiState.copyWith(
      messages: messages,
      currentPersonality: currentPersonality,
      personalityIntensity: personalityIntensity,
      isThinking: isThinking,
      isSpeaking: isSpeaking,
      streamingResponse: streamingResponse,
      currentExpression: currentExpression,
      isChatCollapsed: isChatCollapsed,
      isLocalAiEnabled: isLocalAiEnabled,
      divergenceMeter: divergenceMeter,
      isListening: isListening,
      hapticEnabled: hapticEnabled,
      musicGenre: musicGenre,
      musicModulation: musicModulation,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Web arama (isteğe bağlı fallback)
  // ------------------------------------------------------------------
  Future<String?> webSearch(String query) async {
    final url = 'https://html.duckduckgo.com/html/?q=${Uri.encodeQueryComponent(query)}';
    try {
      final resp = await repository.api.httpClient.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Amadeus/1.0'},
      );
      if (resp.statusCode == 200) return 'Arama başarılı (görünüm içeriği)';
    } on Exception catch (_) {}
    return null;
  }

  Future<void> _showNotification(String title, String body) async {
    await repository.notificationManager.showMessageNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
    );
  }

  void _finalizeAssistantMessage(String response) {
    _updateUiState(
      messages: <ChatMessage>[
        ..._uiState.messages,
        ChatMessage(role: 'assistant', content: response),
      ],
      isThinking: false,
      streamingResponse: '',
    );
  }

  // ------------------------------------------------------------------
  // Konuşma düzeltme (STT ile tekrar dinle)
  // ------------------------------------------------------------------
  Future<void> correctSpeech() async {
    if (!_uiState.isListening) {
      await speechManager.startListening((text) {
        sendMessage(text, null);
      });
      _updateUiState(isListening: true);
    }
  }
}
