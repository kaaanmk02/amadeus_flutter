import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/app_config.dart';

/// Kullanıcı ayarlarını `shared_preferences`'a yazar/okur.
/// `SettingsManager.java` ile anahtar isimleri birebir aynıdır.
class SettingsManager {
  SettingsManager(this._prefs, this._secureStorage);

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  String _apiKeyCache = '';
  static const _secureApiKey = 'amadeus_api_key_v1';
  static const _secureFishApiKey = 'amadeus_fish_audio_api_key_v1';
  String _fishApiKeyCache = '';

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
  static const String kAiEngine = 'ai_engine';
  static const String kUseApiProxy = 'use_api_proxy';

  static Future<SettingsManager> load() async {
    const secure = FlutterSecureStorage();
    final manager = SettingsManager(await SharedPreferences.getInstance(), secure);
    manager._apiKeyCache = await secure.read(key: _secureApiKey) ?? '';
    manager._fishApiKeyCache = await secure.read(key: _secureFishApiKey) ?? '';
    // Eski sürümden kalan düz metin anahtarı güvenli alana taşınır.
    final legacy = manager._prefs.getString(kApiKey);
    if (manager._apiKeyCache.isEmpty && legacy != null && legacy.isNotEmpty && legacy != '[REDACTED]') {
      manager._apiKeyCache = legacy;
      await secure.write(key: _secureApiKey, value: legacy);
    }
    await manager._prefs.remove(kApiKey);
    return manager;
  }

  // ---- api_url ----
  String getApiUrl() => _prefs.getString(kApiUrl) ?? AppConfig.defaultApiUrl;
  Future<void> setApiUrl(String url) => _prefs.setString(kApiUrl, url);

  // ---- model_name ----
  String getModelName() => _prefs.getString(kModelName) ?? AppConfig.defaultModel;
  Future<void> setModelName(String model) => _prefs.setString(kModelName, model);

  bool getUseApiProxy() => _prefs.getBool(kUseApiProxy) ?? false;
  Future<void> setUseApiProxy(bool value) => _prefs.setBool(kUseApiProxy, value);

  // ---- api_key (asla loga/dosyaya yazılmaz) ----
  String getApiKey() => _apiKeyCache;
  String getFishAudioApiKey() => _fishApiKeyCache;
  Future<void> setFishAudioApiKey(String key) async {
    _fishApiKeyCache = key.trim();
    if (_fishApiKeyCache.isEmpty) { await _secureStorage.delete(key: _secureFishApiKey); }
    else { await _secureStorage.write(key: _secureFishApiKey, value: _fishApiKeyCache); }
  }
  Future<void> setApiKey(String key) async {
    _apiKeyCache = key;
    if (key.isEmpty) {
      await _secureStorage.delete(key: _secureApiKey);
    } else {
      await _secureStorage.write(key: _secureApiKey, value: key);
    }
    await _prefs.remove(kApiKey);
  }

  // ---- personality ----
  String getPersonality() => _prefs.getString(kPersonality) ?? 'tsundere';
  Future<void> setPersonality(String type) => _prefs.setString(kPersonality, type);

  // ---- intensity ----
  double getIntensity() =>
      (_prefs.getDouble(kIntensity) ?? 0.7).clamp(0.0, 1.0).toDouble();
  Future<void> setIntensity(double value) =>
      _prefs.setDouble(kIntensity, value.clamp(0.0, 1.0).toDouble());

  // ---- custom_system_prompt ----
  String getCustomSystemPrompt() => _prefs.getString(kCustomSystemPrompt) ?? '';
  Future<void> setCustomSystemPrompt(String prompt) =>
      _prefs.setString(kCustomSystemPrompt, prompt);

  // ---- context_window ----
  int getContextWindow() =>
      (_prefs.getInt(kContextWindow) ?? 10).clamp(2, 50).toInt();
  Future<void> setContextWindow(int value) =>
      _prefs.setInt(kContextWindow, value.clamp(2, 50).toInt());

  // ---- tts_provider ----
  String getTtsProvider() => _prefs.getString(kTtsProvider) ?? AppConfig.defaultTtsProvider;
  Future<void> setTtsProvider(String provider) =>
      _prefs.setString(kTtsProvider, provider);

  // ---- auto_speak ----
  bool getAutoSpeak() => _prefs.getBool(kAutoSpeak) ?? true;
  Future<void> setAutoSpeak(bool value) => _prefs.setBool(kAutoSpeak, value);

  // ---- AI motoru: online / local_gguf ----
  String getAiEngine() => _prefs.getString(kAiEngine) ?? 'online';
  Future<void> setAiEngine(String engine) =>
      _prefs.setString(kAiEngine, const {'online', 'local_gguf', 'rust'}.contains(engine) ? engine : 'online');

  // ---- local_model_path ----
  String? getLocalModelPath() => _prefs.getString(kLocalModelPath);
  Future<void> setLocalModelPath(String? path) async {
    if (path == null) {
      await _prefs.remove(kLocalModelPath);
    } else {
      await _prefs.setString(kLocalModelPath, path);
    }
  }
}
