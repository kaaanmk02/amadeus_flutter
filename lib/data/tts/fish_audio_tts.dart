import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../../../core/app_config.dart';

class FishAudioTts {
  FishAudioTts({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Uint8List?> synthesize({
    required String text,
    String? apiKey,
  }) async {
    try {
      final online = await _isOnline();
      if (!online) return null;
      final uri = Uri.parse(AppConfig.fishAudioApiUrl);
      final body = jsonEncode({
        'text': text,
        'model': AppConfig.fishAudioModel,
        'reference_id': AppConfig.fishAudioReferenceId,
      });
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (apiKey != null && apiKey.isNotEmpty && apiKey != '[REDACTED]')
          'Authorization': 'Bearer $apiKey',
      };
      final resp = await _client.post(uri, headers: headers, body: body);
      if (resp.statusCode == 200) return resp.bodyBytes;
    } on Exception catch (_) {}
    return null;
  }

  Future<bool> _isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } on Exception catch (_) {
      return false;
    }
  }
}