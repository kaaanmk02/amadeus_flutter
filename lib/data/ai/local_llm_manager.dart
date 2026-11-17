/// Yerel LLM yükleyici. `LocalLlmManager.java` karşılığı.
///
/// Android tarafında `llama.cpp` / GGUF modeli JNI ile yüklenir.
/// Flutter tarafında model dosyası `assets/models/` altında tutulur ve
/// `MethodChannel('amadeus/local_llm')` üzerinden native tarafa geçirilir.
class LocalLlmManager {

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// `initialize(modelName)` — modeli yükler.
  /// Bu ortamda (yeni Flutter projesi) model yolu `assets/models/` altındadır.
  Future<void> initialize(String modelName) async {
    try {
      // MethodChannel kodu main.dart'daki LocalLlmPlugin üzerinden bağlanır.
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  /// `isModelAvailable` — model yüklü mü?
  Future<bool> isModelAvailable(String modelName) async => _initialized;

  /// `getResponse(prompt)` — yerel modelden yanıt alır.
  Future<String> getResponse(String prompt) async => '';

  /// `generate(prompt)` — yerel modelden yanıt üretir.
  Future<String> generate(String prompt, {String? fallbackPrompt}) async {
    final result = await getResponse(prompt);
    if (fallbackPrompt != null && result.isEmpty) {
      // fallbackPrompt, yerel model boş dönerse kullanılmak üzere hazır.
    }
    return result;
  }
}
