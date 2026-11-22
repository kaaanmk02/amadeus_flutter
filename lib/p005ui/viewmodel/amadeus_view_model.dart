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
import '../../data/model/assistant_output.dart';
import '../../data/model/kurisu_expression.dart';
import '../../data/model/personality_type.dart';
import '../../data/repository/amadeus_repository.dart';

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
  }) {
    repository.restoreActiveHistory();
    _uiState = AmadeusUiState(
      messages: repository.chatHistory,
      currentPersonality: PersonalityType.fromName(repository.settings.getPersonality()),
      personalityIntensity: repository.settings.getIntensity(),
    );
  }

  final AmadeusRepository repository;
  final SoundManager soundManager;
  final SpeechManager speechManager;
  final LocalLlmManager localLlmManager;

  /// Asistan cevabını seslendirmek için UI katmanına verilen callback.
  final Future<void> Function(String text) onSpeak;

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
  bool get useApiProxy => repository.settings.getUseApiProxy();
  Future<void> setUseApiProxy(bool value) => repository.settings.setUseApiProxy(value);
  String get fishAudioApiKey => repository.settings.getFishAudioApiKey();
  Future<void> setFishAudioApiKey(String value) => repository.settings.setFishAudioApiKey(value);
  PersonalityType get currentPersonality => _uiState.currentPersonality;
  double get personalityIntensity => _uiState.personalityIntensity;
  Future<void> setApiUrl(String value) => repository.settings.setApiUrl(value.trim());
  Future<void> setModelName(String value) => repository.settings.setModelName(value.trim());
  Future<void> setApiKey(String value) => repository.settings.setApiKey(value.trim());
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
  Future<void> saveSettings(String url, String model, String key) async {
    await repository.settings.setApiUrl(url.trim());
    await repository.settings.setModelName(model.trim());
    await repository.settings.setApiKey(key.trim());
  }

  void setPersonality(PersonalityType type) {
    _updateUiState(currentPersonality: type);
    repository.settings.setPersonality(type.name);
  }

  void setIntensity(double intensity) {
    _updateUiState(personalityIntensity: intensity);
    repository.settings.setIntensity(intensity);
  }

  bool get autoSpeak => repository.settings.getAutoSpeak();
  Future<void> setAutoSpeak(bool value) async {
    await repository.settings.setAutoSpeak(value);
  }

  String get ttsProvider => repository.settings.getTtsProvider();
  Future<void> setTtsProvider(String provider) async {
    await repository.settings.setTtsProvider(provider);
  }

  // ---- language / theme ----
  String get language => repository.settings.getLanguage();
  Future<void> setLanguage(String language) async {
    await repository.settings.setLanguage(language);
  }

  String get themeMode => repository.settings.getThemeMode();
  Future<void> setThemeMode(String mode) async {
    await repository.settings.setThemeMode(mode);
  }

  String get aiEngine => repository.settings.getAiEngine();
  Future<void> setAiEngine(String engine) async {
    await repository.settings.setAiEngine(engine);
    _updateUiState(isLocalAiEnabled: engine == 'local_gguf');
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
      final loaded = await service.loadModel(modelPath: path);
      if (!loaded) return null;
      final stream = service.generateStream(prompt);
      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk);
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
  Future<void> startNewSession() async {
    await repository.startNewSession();
    _updateUiState(messages: const <ChatMessage>[], streamingResponse: '', isThinking: false, isSpeaking: false);
  }

  List<Map<String, dynamic>> get archivedSessions => repository.sessionManager.sessions;

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
    speechManager.stopSpeaking();
    _updateUiState(isSpeaking: false);
  }

  void toggleListening() {
    if (_uiState.isListening) {
      speechManager.stopListening();
      _updateUiState(isListening: false);
      return;
    }
    speechManager.startListening((text) {
      _updateUiState(isListening: false);
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

    await repository.memoryManager.rememberExplicitUserStatement(trimmed);

    _updateUiState(
      messages: <ChatMessage>[..._uiState.messages, userMessage],
      isThinking: true,
      streamingResponse: '',
    );

    try {
      if (imageBase64 != null && repository.settings.getAiEngine() != 'online') {
        repository.addMessageToHistory(ChatMessage(role: 'user', content: trimmed.isEmpty ? '[Görsel]' : trimmed));
        const notice = 'Görsel analizi şu an yalnızca çevrim içi, görsel destekleyen bir modelle kullanılabilir. Yerel GGUF ve Rust motorları bu sürümde görsel girdisi almıyor.';
        repository.addMessageToHistory(ChatMessage(role: 'assistant', content: notice));
        _finalizeAssistantMessage(notice);
        return;
      }
      if (repository.settings.getAiEngine() == 'rust') {
        repository.addMessageToHistory(userMessage);
        const message = 'Rust motoru seçildi ancak bu projede Rust/FFI çalışma zamanı henüz bulunmuyor. Çalıştırmak için Android NDK bağlantısı ve Rust native modülü eklenmeli. Şimdilik Çevrim içi veya Yerel GGUF seç.';
        repository.addMessageToHistory(ChatMessage(role: 'assistant', content: message));
        _finalizeAssistantMessage(message);
        return;
      }
      if (repository.settings.getAiEngine() == 'local_gguf') {
        final customPrompt = repository.settings.getCustomSystemPrompt();
        final prompt = repository.personalityManager.getSystemPrompt(
          _uiState.currentPersonality, _uiState.personalityIntensity,
          customPrompt: customPrompt.isEmpty ? null : customPrompt,
        );
        final memories = repository.memoryManager.searchMemories(trimmed, limit: 12).map((m) => '- ${m.content}').join('\n');
        final archived = repository.sessionManager.searchSessions(trimmed, limit: 4)
            .where((session) => session['summary'] != repository.sessionManager.carrySummary)
            .map((session) => '- ${session['summary']}').join('\n');
        final carry = [repository.sessionManager.carrySummary, archived]
            .where((item) => item.trim().isNotEmpty).join('\n\n');
        final recent = repository.chatHistory.take(repository.chatHistory.length).toList();
        final recentText = recent.length > 10 ? recent.sublist(recent.length - 10) : recent;
        final historyText = recentText.map((m) => '${m.role == 'user' ? 'Kullanıcı' : 'Amadeus'}: ${m.content}').join('\n');
        const outputContract =
            'Yanıtını yalnızca geçerli JSON ver: {"reply":"Türkçe yanıt","emotion":"normal|happy|angry|sad|thinking|blush|pissed","intensity":0.0,"confidence":0.0}. JSON dışında metin yazma.';
        final raw = await generateWithLocalGguf('$prompt\n$outputContract\nÖNCEKİ OTURUM ÖZETİ:\n$carry\nİLGİLİ HAFIZA:\n$memories\nSON KONUŞMALAR:\n$historyText\nKullanıcı: $trimmed\nJSON yanıt:');
        if (raw == null || raw.trim().isEmpty) {
          throw ApiException('Yerel GGUF modeli yüklenemedi veya yanıt üretemedi. Ayarlardan modeli indirip yükle.', statusCode: 0);
        }
        final output = AssistantOutput.parse(raw);
        _updateUiState(streamingResponse: output.reply, currentExpression: output.expression, expressionIntensity: output.intensity, isThinking: false);
        onExpressionChanged?.call(output.expression);
        repository.addMessageToHistory(ChatMessage(role: 'user', content: trimmed));
        repository.addMessageToHistory(ChatMessage(role: 'assistant', content: output.reply));
        repository.lastAssistantOutput = output;
        await repository.rotateSessionIfNeeded();
        if (repository.settings.getAutoSpeak()) await _speakReply(output.reply);
        _finalizeAssistantMessage(output.reply);
        return;
      }
      await for (final chunk in repository.sendMessageStream(
        trimmed,
        type: _uiState.currentPersonality,
        intensity: _uiState.personalityIntensity,
        imageBase64: imageBase64,
      )) {
        _updateUiState(streamingResponse: _uiState.streamingResponse + chunk, isSpeaking: true);
        updateExpression(_uiState.streamingResponse);
      }
    } on ApiException catch (e) {
      if (imageBase64 != null) {
        if (repository.chatHistory.isEmpty || repository.chatHistory.last.role != 'user' || repository.chatHistory.last.content != trimmed) {
          repository.addMessageToHistory(ChatMessage(role: 'user', content: '[Görsel] $trimmed'));
        }
        final message = 'Görsel modeli yanıt veremedi: ${e.message}. Görseli analiz etmek için çevrim içi görsel destekli bir model seçmelisin.';
        repository.addMessageToHistory(ChatMessage(role: 'assistant', content: message));
        _finalizeAssistantMessage(message);
        return;
      }
      if (repository.chatHistory.isEmpty || repository.chatHistory.last.role != 'user' || repository.chatHistory.last.content != trimmed) {
        repository.addMessageToHistory(ChatMessage(role: 'user', content: trimmed));
      }
      _updateUiState(streamingResponse: e.message, isThinking: false);
      final customPrompt = repository.settings.getCustomSystemPrompt();
      final fallbackPrompt = repository.personalityManager.getSystemPrompt(
        _uiState.currentPersonality,
        _uiState.personalityIntensity,
        customPrompt: customPrompt.isEmpty ? null : customPrompt,
      );
      final archived = repository.sessionManager.searchSessions(trimmed, limit: 4)
          .where((session) => session['summary'] != repository.sessionManager.carrySummary)
          .map((session) => '- ${session['summary']}').join('\n');
      final carry = [repository.sessionManager.carrySummary, archived]
          .where((item) => item.trim().isNotEmpty).join('\n\n');
      final memories = repository.memoryManager.searchMemories(trimmed, limit: 12)
          .map((m) => '- ${m.content}').join('\n');
      final historyWithoutCurrent = repository.chatHistory.isNotEmpty &&
              repository.chatHistory.last.role == 'user' &&
              repository.chatHistory.last.content == trimmed
          ? repository.chatHistory.sublist(0, repository.chatHistory.length - 1)
          : repository.chatHistory;
      final recent = historyWithoutCurrent.length > 10
          ? historyWithoutCurrent.sublist(historyWithoutCurrent.length - 10)
          : historyWithoutCurrent;
      final context = [
        if (carry.isNotEmpty) 'ÖNCEKİ OTURUM ÖZETİ:\n$carry',
        if (memories.isNotEmpty) 'İLGİLİ HAFIZA:\n$memories',
        if (recent.isNotEmpty) 'SON KONUŞMALAR:\n${recent.map((m) => '${m.role}: ${m.content}').join('\n')}',
      ].join('\n\n');
      String fallback = await localLlmManager.generate(
        '$context\nKullanıcı: $trimmed',
        fallbackPrompt: '$fallbackPrompt\nYanıtını Türkçe ver. Duygunu doğal biçimde yansıt.',
      );
      if (fallback.isEmpty) {
        final String? ggufResult = await generateWithLocalGguf(
          '$fallbackPrompt\n$context\nKullanıcı: $trimmed\nAsistan:',
        );
        if (ggufResult != null && ggufResult.isNotEmpty) {
          fallback = ggufResult;
        }
      }
      if (fallback.isNotEmpty) {
        final output = AssistantOutput.parse(fallback);
        final answer = output.reply;
        repository.addMessageToHistory(ChatMessage(role: 'assistant', content: answer));
        repository.lastAssistantOutput = output;
        _updateUiState(currentExpression: output.expression, expressionIntensity: output.intensity, streamingResponse: answer, isThinking: false);
        onExpressionChanged?.call(output.expression);
        await repository.rotateSessionIfNeeded();
        _finalizeAssistantMessage(answer);
        if (repository.settings.getAutoSpeak()) await _speakReply(answer);
        return;
      }
      final message = 'Bağlantı kurulamadı: ${e.message}';
      repository.addMessageToHistory(ChatMessage(role: 'assistant', content: message));
      _finalizeAssistantMessage(message);
      _showNotification('Bağlantı Hatası', e.message);
      return;
    } on Exception catch (e) {
      final message = 'Hata: $e';
      _finalizeAssistantMessage(message);
      _showNotification('Hata', '$e');
      return;
    }

    if (_uiState.streamingResponse.isNotEmpty) {
      final output = repository.lastAssistantOutput;
      if (output != null) {
        _updateUiState(currentExpression: output.expression, expressionIntensity: output.intensity);
        onExpressionChanged?.call(output.expression);
      }
      if (repository.settings.getAutoSpeak()) { await _speakReply(_uiState.streamingResponse); }
      _finalizeAssistantMessage(_uiState.streamingResponse);
      _showNotification('Kurisu', _uiState.streamingResponse.length > 120
          ? _uiState.streamingResponse.substring(0, 120)
          : _uiState.streamingResponse);
    } else {
      _updateUiState(isThinking: false);
    }
  }

  /// `sendMessageDirectly` — kullanıcı mesajı eklemeden salt asistan cevabı.
  Future<void> sendMessageDirectly(String response) async {
    await repository.sendMessageDirectly(response);
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
  // İfade + Divergence
  // ------------------------------------------------------------------
  /// `updateExpression` — metindeki anahtar kelimelere göre Kurisu ifadesini seçer.
  void updateExpression(String text) {
    final lower = text.toLowerCase();
    KurisuExpression next;
    if (lower.contains('baka') ||
        lower.contains('aptal') ||
        lower.contains('sapik') ||
        lower.contains('haddini bil')) {
      next = KurisuExpression.angry;
    } else if (lower.contains('hos') ||
        lower.contains('guzel') ||
        lower.contains('cok tesekkur')) {
      next = KurisuExpression.happy;
    } else if (lower.contains('utandim') || lower.contains('mahrum')) {
      next = KurisuExpression.blush;
    } else if (lower.contains('uzgun') ||
        lower.contains('malesef') ||
        lower.contains('olum')) {
      next = KurisuExpression.sad;
    } else if (lower.contains('hmm') ||
        lower.contains('dusunuyorum') ||
        lower.contains('belki')) {
      next = KurisuExpression.thinking;
    } else {
      next = _uiState.currentExpression;
    }
    if (next != _uiState.currentExpression) {
      _updateUiState(currentExpression: next);
      onExpressionChanged?.call(next);
    }
  }

  /// `updateDivergence` — 0.00000000 - 1.10000000 arası rastgele değer üretir.
  void updateDivergence() {
    _updateUiState(divergenceMeter: repository.nextDivergence());
  }

  // ==== MÜZİK YÖNETİMİ ====

  /// Müzik çalıyor demek için sondaj (toggle).
  void toggleMusic() {
    soundManager.play('music');
  }

  /// Müzik durdurma.
  void stopMusic() {
    soundManager.stopAllAudio();
  }

  /// Bir sonraki şarkıya atla.
  void nextMusic() {
    soundManager.next();
  }

  /// Bir sonraki şarkıya atla (geri).
  void prevMusic() {
    soundManager.next();
  }

  /// Çarkı liste indexine ayarla.
  void setPlaylistIndex(int idx) {
    if (idx >= 0) {
      soundManager.play('music');
    }
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
    double? expressionIntensity,
    bool? isChatCollapsed,
    bool? isLocalAiEnabled,
    String? divergenceMeter,
    bool? isListening,
  }) {
    _uiState = _uiState.copyWith(
      messages: messages,
      currentPersonality: currentPersonality,
      personalityIntensity: personalityIntensity,
      isThinking: isThinking,
      isSpeaking: isSpeaking,
      streamingResponse: streamingResponse,
      currentExpression: currentExpression,
      expressionIntensity: expressionIntensity,
      isChatCollapsed: isChatCollapsed,
      isLocalAiEnabled: isLocalAiEnabled,
      divergenceMeter: divergenceMeter,
      isListening: isListening,
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
    // Web araması henüz bir arama sağlayıcısına bağlanmadı.
    // Başarılıymış gibi sahte sonuç döndürmek yerine null döndür.
    return null;
  }

  void _showNotification(String title, String body) {
    // Bildirim servisi henüz ViewModel'e enjekte edilmedi.
    // Hassas içerik yerine yalnızca başlık ve hata özeti debug konsoluna yazılır.
    debugPrint('Amadeus [$title]: $body');
  }


  Future<void> _speakReply(String text) async {
    _updateUiState(isSpeaking: true);
    try {
      await onSpeak(text);
    } finally {
      _updateUiState(isSpeaking: false);
    }
  }

  // ------------------------------------------------------------------
  // MÜZİK / PLAYER
  // ------------------------------------------------------------------
  Future<void> playAudio() => soundManager.play('music');
  Future<void> loopAudio() => soundManager.loop('music');
  Future<void> skipAudio() => soundManager.next();

  bool get micMuted => soundManager.muted;
  Future<void> toggleMicMute() => soundManager.mute();

  void _finalizeAssistantMessage(String response) {
    _updateUiState(
      messages: <ChatMessage>[
        ..._uiState.messages,
        ChatMessage(role: 'assistant', content: response),
      ],
      isThinking: false,
      isSpeaking: false,
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
