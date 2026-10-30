import 'dart:math';

import '../model/chat_message.dart';
import '../model/personality_type.dart';
import '../network/llm_api.dart';
import '../storage/settings_manager.dart';
import '../storage/memory_manager.dart';
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
  });

  final LlmApi api;
  final SettingsManager settings;
  final PersonalityManager personalityManager;
  final MemoryManager memoryManager;

  final List<ChatMessage> _chatHistory = <ChatMessage>[];

  List<ChatMessage> get chatHistory => List<ChatMessage>.unmodifiable(_chatHistory);

  void addMessageToHistory(ChatMessage message) => _chatHistory.add(message);

  void clearHistory() => _chatHistory.clear();

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
    final systemPrompt = personalityManager.getSystemPrompt(
      type,
      intensity,
      customPrompt: customPrompt.isEmpty ? null : customPrompt,
    );

    final messages = <ChatMessage>[
      ChatMessage(role: 'system', content: systemPrompt),
      ..._takeLast(settings.getContextWindow(), skipLast: true),
    ];

    final userMessage = ChatMessage(
      role: 'user',
      content: content,
      imageBase64: imageBase64,
      imageList: imageBase64 != null ? [imageBase64] : null,
    );
    messages.add(userMessage);

    final fullResponse = StringBuffer();

    try {
      await for (final chunk in api.generateStream(messages)) {
        fullResponse.write(chunk);
        yield chunk;
      }
    } on ApiException {
      rethrow;
    } on Exception {
      yield 'Baglanti Hatasi: Sunucuya ulasilamiyor. '
          'Lutfen ag ayarlarini ve PC\'deki Ollama/LM Studio durumunu kontrol et.';
      return;
    }

    if (fullResponse.isNotEmpty) {
      addMessageToHistory(ChatMessage(
        role: 'assistant',
        content: fullResponse.toString(),
      ));
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

  List<ChatMessage> _takeLast(int n, {bool skipLast = false}) {
    final effective = skipLast ? _chatHistory.length - 1 : _chatHistory.length;
    if (effective <= 0) return <ChatMessage>[];
    final start = effective - n < 0 ? 0 : effective - n;
    return _chatHistory.sublist(start, effective);
  }
}
