/// Yerel LLM yükleyici. `LocalLlmManager.java` karşılığı.
///
/// Android tarafında `llama.cpp` / GGUF modeli JNI ile yüklenir.
/// Flutter tarafında model dosyası `assets/models/` altında tutulur ve
/// `MethodChannel('amadeus/local_llm')` üzerinden native tarafa geçirilir.
import 'package:flutter/foundation.dart';
import 'llama_gguf_service.dart';

class LocalLlmManager {
  LocalLlmManager._();

  static final LocalLlmManager instance = LocalLlmManager._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  LlamaGgufService? _ggufService;

  /// Mevcut GGUF servisini kullanmak isterseniz buradan elde edilir.
  LlamaGgufService? get ggufService => _ggufService;

  Future<void> initialize(String modelName) async {
    try {
      // MethodChannel kodu main.dart'daki LocalLlmPlugin üzerinden bağlanır.
      // Ana sert: gerçek bir GGUF servisi başlatmak.
      _ggufService ??= LlamaGgufService.instance;
      _initialized = true;
    } catch (e) {
      _initialized = false;
      debugPrint('LocalLlmManager.initialize error: $e');
    }
  }

  /// `isModelAvailable` — model yüklü mü?
  Future<bool> isModelAvailable(String modelName) async => _initialized;

  /// `getResponse(prompt)` — yerel modelden yanıt alır.
  Future<String> getResponse(String prompt) async {
    if (!_initialized || _ggufService == null) return '';
    try {
      return await _ggufService!.generateStream(prompt).fold(
        '',
        (acc, chunk) => acc + chunk,
      );
    } catch (e) {
      debugPrint('LocalLlmManager.getResponse error: $e');
      return '';
    }
  }

  /// `generate(prompt)` — yerel modelden yanıt üretir.
  Future<String> generate(String prompt, {String? fallbackPrompt}) async {
    final result = await getResponse(prompt);
    if (fallbackPrompt != null && result.isEmpty) {
      // fallbackPrompt, yerel model boş dönerse kullanılmak üzere hazır.
    }
    return result;
  }
}
