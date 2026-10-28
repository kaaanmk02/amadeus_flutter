/// Uygulama genelinde kullanilan sabitler.
///
/// API anahtari / model adi / API adresi burada tutulmaz.
/// `SettingsManager` uzerinden `shared_preferences`'a yazilir
/// (bkz. `lib/data/storage/settings_manager.dart`).
class AppConfig {
  static const String appName = 'AMADEUS';
  static const String appVersion = '1.0.0';

  /// Varsayilan model adi (SettingsManager ile birebir ayni).
  static const String defaultModel = 'llama3';

  /// Varsayilan API adresi. Android emulatöründe host makine 10.0.2.2'dir.
  static const String defaultApiUrl = 'http://10.0.2.2:11434/';

  /// Ollama uyumlu endpoint'e dönüstürülürken kullanilan sabitler.
  static const String fallbackApiUrl = 'http://127.0.0.1:11434/v1/';
  static const String openAiPath = '/v1/';

  // TTS
  static const String defaultTtsProvider = 'online';
  static const String onlineTtsProvider = 'online';
  static const String offlineTtsProvider = 'offline';
  static const String fishAudioApiUrl = 'https://api.fish.audio/v1/tts';
  static const String fishAudioModel = 's2.1-pro-free';
  static const String fishAudioReferenceId = 'b450b19370434173b121446057622e9b';
  static const String offlineTtsAssetDir = 'assets/tts/';

  // offline gguf
  static const String defaultLocalModelName = 'qwen2.5-3b-instruct-q4km';
  static const String localModelFileName = 'qwen2.5-3b-instruct-q4km.gguf';
  static const String localModelHfRepo = 'unsloth/qwen2.5-3b-instruct-GGUF';
  static const String localModelHfFile = 'qwen2.5-3b-instruct-Q4_K_M.gguf';
  static const int localModelContextSize = 2048;
  static const int localModelThreads = 4;

  /// Baglanti / okuma / yazma zaman asimlari (ApiClient ile ayni).
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration readTimeout = Duration(seconds: 120);
  static const Duration writeTimeout = Duration(seconds: 15);

  /// Model adi bosssa kullanilan yedek (AmadeusRepository ile ayni).
  static const String fallbackModel = 'llama3-vision';

  /// Sohbet gecmisinde modele gönderilen maksimum mesaj sayisi.
  static const int maxHistoryMessages = 10;

  /// Asistan seslendirmesi ardindan düsünme durumunun sifirlanma süresi.
  static const Duration speakResetDelay = Duration(milliseconds: 4000);
}
