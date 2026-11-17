import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';
import '../../core/exceptions.dart';
import '../model/chat_message.dart';
import '../storage/settings_manager.dart';

/// OpenAI uyumlu /v1/chat/completions uç noktasına SSE akışı gönderir.
class LlmApi {
  LlmApi({required this.settings, http.Client? client, this.baseUrlOverride})
      : _client = client ?? http.Client();

  final SettingsManager settings;
  final http.Client _client;
  final String? baseUrlOverride;

  String get baseUrl {
    final configured = (baseUrlOverride ?? settings.getApiUrl()).trim();
    if (configured.isEmpty) {
      throw ApiException('API adresi boş. Ayarlardan bir adres gir.', statusCode: 0);
    }

    final uri = Uri.tryParse(configured);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty || !['http', 'https'].contains(uri.scheme)) {
      throw ApiException('Geçersiz API adresi: $configured', statusCode: 0);
    }

    final isLoopback = uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '10.0.2.2';
    if (uri.scheme != 'https' && !isLoopback) {
      throw ApiException('Güvenlik için internet üzerindeki API adresi HTTPS kullanmalı.', statusCode: 0);
    }

    var path = uri.path.replaceFirst(RegExp(r'/+$'), '');
    if (path.endsWith('/chat/completions')) {
      // Tam endpoint verilmiş.
    } else if (path.endsWith('/v1')) {
      path += '/chat/completions';
    } else {
      path += '/v1/chat/completions';
    }
    return uri.replace(path: path, query: null, fragment: null).toString();
  }

  String get apiKey => settings.getApiKey().trim();

  Stream<String> generateStream(List<ChatMessage> messages) async* {
    final uri = Uri.parse(baseUrl);
    final model = settings.getModelName().trim();
    final body = <String, dynamic>{
      'model': model.isEmpty ? AppConfig.fallbackModel : model,
      'messages': messages.map(_encodeMessage).toList(growable: false),
      'stream': true,
    };

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..body = jsonEncode(body);

    final key = apiKey;
    if (settings.getUseApiProxy()) {
      if (key.isNotEmpty && key != '[REDACTED]') request.headers['x-amadeus-proxy-token'] = key;
    } else if (key.isNotEmpty && key != '[REDACTED]') {
      request.headers['Authorization'] = 'Bearer $key';
    }

    late final http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(AppConfig.connectTimeout);
    } on TimeoutException {
      throw ApiException('API bağlantısı zaman aşımına uğradı.', statusCode: 0);
    } on Exception {
      throw ApiException(
        'Sunucuya ulaşılamıyor. API adresini, cihazın ağ bağlantısını ve sunucunun açık olduğunu kontrol et.',
        statusCode: 0,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = await response.stream.bytesToString();
      throw ApiException(
        error.isEmpty ? 'Sunucu HTTP ${response.statusCode} döndürdü.' : error,
        statusCode: response.statusCode,
      );
    }

    // LineSplitter, ağ paketleri arasında bölünen SSE satırlarını doğru birleştirir.
    try {
      await for (final line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(AppConfig.readTimeout)) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data:')) continue;
        final payload = trimmed.substring(5).trim();
        if (payload == '[DONE]') return;
        if (payload.isEmpty) continue;

        try {
          final decoded = jsonDecode(payload);
          if (decoded is! Map<String, dynamic>) continue;
          final choices = decoded['choices'];
          if (choices is! List || choices.isEmpty) continue;
          final first = choices.first;
          if (first is! Map<String, dynamic>) continue;
          final delta = first['delta'];
          if (delta is! Map<String, dynamic>) continue;
          final content = delta['content'];
          if (content is String && content.isNotEmpty) yield content;
        } on FormatException {
          // Keep-alive or malformed event: ignore it and continue.
        }
      }
    } on TimeoutException {
      throw ApiException('Model yanıtı beklenirken zaman aşımı oluştu.', statusCode: 0);
    }
  }


  /// Summarizes a completed session into durable, compact context.
  /// Falls back to SessionManager's extractive summary if this endpoint is unavailable.
  Future<String> summarizeSession(List<ChatMessage> messages) async {
    final transcript = messages
        .where((m) => m.role == 'user' || m.role == 'assistant')
        .map((m) => '${m.role == 'user' ? 'Kullanıcı' : 'Amadeus'}: ${m.content}')
        .join('\n');
    final clipped = transcript.length > 14000
        ? transcript.substring(transcript.length - 14000)
        : transcript;
    if (clipped.trim().isEmpty) return '';
    final request = http.Request('POST', Uri.parse(baseUrl))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': settings.getModelName().trim().isEmpty
            ? AppConfig.fallbackModel
            : settings.getModelName().trim(),
        'stream': false,
        'temperature': 0.2,
        'max_tokens': 600,
        'messages': [
          {
            'role': 'system',
            'content': 'Create a concise factual session memory in Turkish. Preserve user-stated preferences, ongoing projects, decisions, unresolved tasks, important facts and names. Separate confirmed facts from assumptions. Do not invent. Use headings: KULLANICI BAĞLAMI, PROJE DURUMU, KARARLAR, AÇIK İŞLER. Maximum 2500 characters.'
          },
          {'role': 'user', 'content': clipped},
        ],
      });
    final key = apiKey;
    if (settings.getUseApiProxy()) {
      if (key.isNotEmpty && key != '[REDACTED]') request.headers['x-amadeus-proxy-token'] = key;
    } else if (key.isNotEmpty && key != '[REDACTED]') {
      request.headers['Authorization'] = 'Bearer $key';
    }
    final response = await _client.send(request).timeout(AppConfig.connectTimeout);
    final body = await response.stream.bytesToString().timeout(AppConfig.readTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Oturum özeti HTTP ${response.statusCode} döndürdü.', statusCode: response.statusCode);
    }
    final decoded = jsonDecode(body);
    final summary = decoded['choices']?[0]?['message']?['content'];
    if (summary is! String || summary.trim().isEmpty) {
      throw ApiException('Model oturum özeti üretmedi.', statusCode: 0);
    }
    final cleaned = summary.trim();
    return cleaned.substring(0, cleaned.length.clamp(0, 3000).toInt());
  }

  /// Türkçe metni Japonca konuşma metnine çevirir. Sohbet geçmişi gönderilmez;
  /// yalnızca tek metin ve kısa görev talimatı kullanılır.
  Future<String> translateToJapanese(String text) async {
    if (text.trim().isEmpty) return text;
    final uri = Uri.parse(baseUrl);
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': settings.getModelName().trim().isEmpty ? AppConfig.fallbackModel : settings.getModelName().trim(),
        'stream': false,
        'temperature': 0.1,
        'messages': [
          {'role': 'system', 'content': 'Translate the user text into natural spoken Japanese. Return only the Japanese translation. Preserve names and meaning. Do not add explanations.'},
          {'role': 'user', 'content': text},
        ],
      });
    final key = apiKey;
    if (settings.getUseApiProxy()) {
      if (key.isNotEmpty && key != '[REDACTED]') request.headers['x-amadeus-proxy-token'] = key;
    } else if (key.isNotEmpty && key != '[REDACTED]') {
      request.headers['Authorization'] = 'Bearer $key';
    }
    final response = await _client.send(request).timeout(AppConfig.connectTimeout);
    final body = await response.stream.bytesToString().timeout(AppConfig.readTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Çeviri servisi HTTP ${response.statusCode} döndürdü.', statusCode: response.statusCode);
    }
    final decoded = jsonDecode(body);
    final result = decoded['choices']?[0]?['message']?['content'];
    if (result is! String || result.trim().isEmpty) throw ApiException('Japonca çeviri boş döndü.', statusCode: 0);
    return result.trim();
  }

  Map<String, dynamic> _encodeMessage(ChatMessage message) {
    final image = message.imageBase64;
    if (message.role == 'user' && image != null && image.isNotEmpty) {
      final dataUrl = image.startsWith('data:')
          ? image
          : 'data:image/jpeg;base64,$image';
      return {
        'role': message.role,
        'content': [
          {'type': 'text', 'text': message.content},
          {
            'type': 'image_url',
            'image_url': {'url': dataUrl},
          },
        ],
      };
    }
    return {'role': message.role, 'content': message.content};
  }

  void dispose() => _client.close();
}
