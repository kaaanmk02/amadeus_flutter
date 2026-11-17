import 'dart:math';
import 'dart:async';

import '../model/chat_message.dart';
import '../model/assistant_output.dart';
import '../model/personality_type.dart';
import '../network/llm_api.dart';
import '../storage/settings_manager.dart';
import '../storage/memory_manager.dart';
import '../storage/session_manager.dart';
import '../../domain/personality_manager.dart';
import '../../core/exceptions.dart';

/// `AmadeusRepository.java` karsiligi.
/// Sohbet gecmisini yönetir ve modele akis gönderir.
class AmadeusRepository {
  AmadeusRepository({
    required this.api,
    required this.settings,
    required this.personalityManager,
    required this.memoryManager,
    required this.sessionManager,
  });

  final LlmApi api;
  final SettingsManager settings;
  final PersonalityManager personalityManager;
  final MemoryManager memoryManager;
  final SessionManager sessionManager;
  static const int _maxSessionMessages = 24;
  static const int _maxEstimatedContextChars = 18000;

  final List<ChatMessage> _chatHistory = <ChatMessage>[];
  AssistantOutput? lastAssistantOutput;

  void restoreActiveHistory() {
    if (_chatHistory.isEmpty) _chatHistory.addAll(sessionManager.activeMessages);
  }

  List<ChatMessage> get chatHistory => List<ChatMessage>.unmodifiable(_chatHistory);

  void addMessageToHistory(ChatMessage message) {
    _chatHistory.add(message);
    unawaited(sessionManager.saveActiveMessages(_chatHistory));
  }

  void clearHistory() {
    _chatHistory.clear();
    unawaited(sessionManager.saveActiveMessages(_chatHistory));
  }

  /// `sendMessageStream$default` karsiligi.
  ///
  /// Akis: sistem promptu + son N kullanicidan önceki gecmis + yeni kullanici mesaji.
  /// Kullanici mesaji `_chatHistory`'ye eklemez (Java'da da eklenmez;
  /// ViewModel mesaji sadece UI listesine ekler).
  Stream<String> sendMessageStream(
    String content, {
    PersonalityType type = PersonalityType.tsundere,
    double intensity = 0.7,
    String? imageBase64,
  }) async* {
    final customPrompt = settings.getCustomSystemPrompt();
    final savedMemories = memoryManager.searchMemories(content, limit: 12);
    final memoryContext = savedMemories.map((m) => '- ${m.content}').join('\n');
    final archived = sessionManager.searchSessions(content, limit: 4)
        .where((s) => s['summary'] != sessionManager.carrySummary)
        .map((s) => '- ${s['summary']}').join('\n');
    final carry = [sessionManager.carrySummary, archived]
        .where((s) => s.trim().isNotEmpty).join('\n\n');
    final systemPrompt = personalityManager.getSystemPrompt(
      type,
      intensity,
      customPrompt: customPrompt.isEmpty ? null : customPrompt,
      memoryContext: memoryContext,
      sessionContext: carry,
    );

    final messages = <ChatMessage>[
      ChatMessage(role: 'system', content: systemPrompt),
      ..._takeLast(settings.getContextWindow().clamp(2, 20)),
    ];

    final userMessage = ChatMessage(
      role: 'user',
      content: content,
      imageBase64: imageBase64,
      imageList: imageBase64 != null ? [imageBase64] : null,
    );
    messages.add(userMessage);
    addMessageToHistory(userMessage);

    final fullResponse = StringBuffer();

    try {
      await for (final chunk in api.generateStream(messages)) { fullResponse.write(chunk); }
    } on ApiException { rethrow; } on Exception catch (error) {
      throw ApiException('İstek tamamlanamadı: $error', statusCode: 0);
    }

    if (fullResponse.isNotEmpty) {
      final output = AssistantOutput.parse(fullResponse.toString());
      lastAssistantOutput = output;
      addMessageToHistory(ChatMessage(role: 'assistant', content: output.reply));
      await rotateSessionIfNeeded();
      // UI'ye JSON değil, kullanıcıya gösterilecek doğal yanıt iletilir.
      yield output.reply;
    }
  }

  /// `sendMessageDirectly` — kullanici mesaji eklemeden salt asistan cevabi.
  Future<void> sendMessageDirectly(String response) async {
    addMessageToHistory(ChatMessage(role: 'assistant', content: response));
  }

  /// `updateDivergence` karsiligi: 0.00000000 - 1.10000000 arasi rastgele deger.
  String nextDivergence() {
    final raw = (Random().nextDouble() * 1.1).toString();
    return raw.length > 8 ? raw.substring(0, 8) : raw;
  }

  Future<void> startNewSession() async {
    String? summary;
    try { summary = await api.summarizeSession(_chatHistory); } catch (_) {}
    await sessionManager.closeAndStart(_chatHistory, summaryOverride: summary);
    _chatHistory.clear();
    await sessionManager.saveActiveMessages(_chatHistory);
  }

  Future<void> rotateSessionIfNeeded() async {
    final chars = _chatHistory.fold<int>(0, (sum, m) => sum + m.content.length);
    if (_chatHistory.length < _maxSessionMessages && chars < _maxEstimatedContextChars) return;
    String? summary;
    try { summary = await api.summarizeSession(_chatHistory); } catch (_) {}
    await sessionManager.closeAndStart(_chatHistory, summaryOverride: summary);
    _chatHistory.clear();
  }

  List<ChatMessage> _takeLast(int n) {
    final effective = _chatHistory.length;
    if (effective <= 0) return <ChatMessage>[];
    final start = effective - n < 0 ? 0 : effective - n;
    return _chatHistory.sublist(start, effective);
  }
}
