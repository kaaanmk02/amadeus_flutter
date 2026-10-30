import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../../core/app_config.dart';
import '../../core/exceptions.dart';
import '../model/chat_message.dart';
import '../storage/settings_manager.dart';

/// `LlmApi.java` + `ApiClient.java` karsiligi.
/// OpenAI-uyumlu `/v1/chat/completions` endpoint'ine SSE akisi gönderir.
class LlmApi {
  LlmApi({required this.settings, http.Client? client, this.baseUrlOverride})
      : _client = client ?? http.Client();

  final SettingsManager settings;
  final http.Client _client;

  /// Testler icin adrese override; null ise ayarlardaki URL kullanilir.
  final String? baseUrlOverride;

  /// Ayar URL'sini OpenAI-uyumlu `/v1/chat/completions` adresine dönüstürür.
  /// Verilen deger `http://host:port/`, `http://host:port` veya
  /// `http://host:port/v1` biciminde olabilir.
  String get baseUrl {
    if (baseUrlOverride != null) {
      return baseUrlOverride!.endsWith('/')
          ? '${baseUrlOverride}chat/completions'
          : '$baseUrlOverride/chat/completions';
    }

    var url = settings.getApiUrl().trim();
    if (url.endsWith('/v1/')) {
      url = url.substring(0, url.length - 1);
    } else if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return '$url/chat/completions';
  }

  String get apiKey => settings.getApiKey();

  /// Kotlin `LlmApi.generateStream` karsiligi.
  /// SSE satirlarini `data:` önekini kaziyip `choices[].delta.content` alanini döndürür.
  Stream<String> generateStream(List<ChatMessage> messages) async* {
    final uri = Uri.parse(baseUrl);
    final modelName = settings.getModelName().trim();
    final body = jsonEncode(<String, dynamic>{
      'model': modelName.isEmpty ? AppConfig.fallbackModel : modelName,
      'messages': messages
          .map((m) => <String, dynamic>{'role': m.role, 'content': m.content})
          .toList(growable: false),
      'stream': true,
    });

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = body;

    if (apiKey.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $apiKey';
    }

    http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(AppConfig.readTimeout);
    } on Exception {
      throw ApiException(
        'Baglanti Hatasi: Sunucuya ulasilamiyor. '
        'Lutfen ag ayarlarini ve PC\'deki Ollama/LM Studio durumunu kontrol et.',
        statusCode: 0,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final err = await response.stream.bytesToString();
      throw ApiException(err.isEmpty ? 'Unknown Error' : err,
          statusCode: response.statusCode);
    }

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      for (final line in chunk.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;
        final payload = trimmed.substring(5).trim();
        if (payload == '[DONE]') return;
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;
          final delta = (choices.first as Map<String, dynamic>)['delta']
              as Map<String, dynamic>?;
          final content = delta?['content'] as String?;
          if (content != null && content.isNotEmpty) yield content;
        } on FormatException {
          // Bozuk satir: atla.
        }
      }
    }
  }

  void dispose() => _client.close();
}
