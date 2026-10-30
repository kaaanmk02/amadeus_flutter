import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_config.dart';

/// Kullanıcı ayarlarını `shared_preferences`'a yazar/okur.
/// `SettingsManager.java` ile anahtar isimleri birebir aynıdır.
class SettingsManager {
  SettingsManager(this._prefs);

  final SharedPreferences _prefs;

  static const String kApiUrl = 'api_url';
  static const String kModelName = 'model_name';
  static const String kApiKey = 'api_key';
  static const String kPersonality = 'personality';
  static const String kIntensity = 'personality_intensity';
  static const String kCustomSystemPrompt = 'custom_system_prompt';
  static const String kContextWindow = 'context_window';
  static const String kTtsProvider = 'tts_provider';
  static const String kAutoSpeak = 'auto_speak';
  static const String kLocalModelPath = 'local_model_path';
  static const String kMusicGenre = 'music_genre';

  static Future<SettingsManager> load() async =>
      SettingsManager(await SharedPreferences.getInstance());

  // ---- api_url ----
  String getApiUrl() => _prefs.getString(kApiUrl) ?? AppConfig.defaultApiUrl;
  Future<void> setApiUrl(String url) => _prefs.setString(kApiUrl, url);

  // ---- model_name ----
  String getModelName() => _prefs.getString(kModelName) ?? AppConfig.defaultModel;
  Future<void> setModelName(String model) => _prefs.setString(kModelName, model);

  // ---- api_key (asla loga/dosyaya yazılmaz) ----
  String getApiKey() => _prefs.getString(kApiKey) ?? '[REDACTED]';
  Future<void> setApiKey(String key) async => _prefs.setString(kApiKey, key);

  // ---- personality ----
  String getPersonality() => _prefs.getString(kPersonality) ?? 'tsundere';
  Future<void> setPersonality(String type) => _prefs.setString(kPersonality, type);

  // ---- intensity ----
  double getIntensity() =>
      (_prefs.getDouble(kIntensity) ?? 0.7).clamp(0.0, 1.0).toDouble();
  Future<void> setIntensity(double value) =>
      _prefs.setDouble(kIntensity, value.clamp(0.0, 1.0));

  // ---- custom_system_prompt ----
  String getCustomSystemPrompt() => _prefs.getString(kCustomSystemPrompt) ?? '';
  Future<void> setCustomSystemPrompt(String prompt) =>
      _prefs.setString(kCustomSystemPrompt, prompt);

  // ---- context_window ----
  int getContextWindow() =>
      (_prefs.getInt(kContextWindow) ?? 10).clamp(2, 50);
  Future<void> setContextWindow(int value) =>
      _prefs.setInt(kContextWindow, value.clamp(2, 50));

  // ---- tts_provider ----
  String getTtsProvider() => _prefs.getString(kTtsProvider) ?? AppConfig.defaultTtsProvider;
  Future<void> setTtsProvider(String provider) =>
      _prefs.setString(kTtsProvider, provider);

  // ---- auto_speak ----
  bool getAutoSpeak() => _prefs.getBool(kAutoSpeak) ?? true;
  Future<void> setAutoSpeak(bool value) => _prefs.setBool(kAutoSpeak, value);

  // ---- haptic_enabled ----
  bool getHapticEnabled() => _prefs.getBool('haptic_enabled') ?? true;
  Future<void> setHapticEnabled(bool value) => _prefs.setBool('haptic_enabled', value);

  // ---- local_model_path ----
  String? getLocalModelPath() => _prefs.getString(kLocalModelPath);
  Future<void> setLocalModelPath(String? path) async {
    if (path == null) {
      await _prefs.remove(kLocalModelPath);
    } else {
      await _prefs.setString(kLocalModelPath, path);
    }
  }

  // ---- music_genre ----
  String getMusicGenre() => _prefs.getString(kMusicGenre) ?? '';
  Future<void> setMusicGenre(String genre) => _prefs.setString(kMusicGenre, genre);

}
