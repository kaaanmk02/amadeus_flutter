import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:speech_to_text/speech_to_text.dart';
import '../../core/app_config.dart';
import '../storage/settings_manager.dart';
import '../tts/fish_audio_tts.dart';

class SpeechManager {
  // _settings mutable olduğu için (configure ile yeniden atanabilir) initializing
  // formal yerine açık atama kullanıyoruz.
  // ignore: prefer_initializing_formals
  SpeechManager({required SettingsManager? settings})
      : _settings = settings,
        _tts = FlutterTts(),
        _stt = SpeechToText(),
        _audioPlayer = AudioPlayer();

  SettingsManager? _settings;
  void configure(SettingsManager settings) { _settings = settings; }
  final FlutterTts _tts;
  final SpeechToText _stt;
  final AudioPlayer _audioPlayer;

  bool _sttReady = false;
  Future<void> _speechQueue = Future<void>.value();
  bool get isSttReady => _sttReady;

  Future<void> speak(String text) {
    final task = _speechQueue.then((_) async {
      final provider = _settings?.getTtsProvider() ?? AppConfig.defaultTtsProvider;
      if (provider == AppConfig.onlineTtsProvider) { await _speakOnline(text); }
      else { await _speakOffline(text); }
    });
    _speechQueue = task.catchError((_) {});
    return task;
  }

  Future<void> _speakOffline(String text) async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _speakOnline(String text) async {
    final online = await _isOnline();
    if (!online) {
      await _speakOffline(text);
      return;
    }
    try {
      final apiKey = _settings?.getFishAudioApiKey() ?? '';
      final bytes = await FishAudioTts().synthesize(
        text: text,
        apiKey: apiKey == '[REDACTED]' ? null : apiKey.trim(),
      );
      if (bytes == null) {
        await _speakOffline(text);
        return;
      }
      final dir = await Directory.systemTemp.createTemp('amadeus_tts_');
      final extension = _audioExtension(bytes);
      final file = File('${dir.path}/tts.$extension');
      await file.writeAsBytes(bytes, flush: true);
      try {
        await _audioPlayer.play(DeviceFileSource(file.path));
        await _audioPlayer.onPlayerComplete.first.timeout(const Duration(minutes: 3));
      } finally {
        try { await file.delete(); await dir.delete(); } catch (_) {}
      }
    } catch (_) {
      await _speakOffline(text);
    }
  }

  String _audioExtension(List<int> bytes) {
    if (bytes.length >= 12 && String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF') return 'wav';
    if (bytes.length >= 3 && bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) return 'mp3';
    if (bytes.length >= 4 && bytes[0] == 0x4f && bytes[1] == 0x67 && bytes[2] == 0x67 && bytes[3] == 0x53) return 'ogg';
    return 'mp3';
  }

  Future<bool> _isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } on Exception catch (_) {
      return false;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
      await _audioPlayer.stop();
    } catch (_) {}
  }

  Future<bool> startListening(void Function(String) onResult) async {
    if (!_sttReady) {
      try {
        _sttReady = await _stt.initialize();
      } catch (_) {
        _sttReady = false;
      }
    }
    if (!_sttReady) return false;
    _stt.listen(
      onResult: (result) {
        // Ignore interim hypotheses: only a final recognition becomes a chat message.
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          onResult(result.recognizedWords.trim());
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'tr_TR',
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 3),
      ),
    );
    return true;
  }

  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  void dispose() {
    _speechQueue = Future<void>.value();
    _tts.stop();
    _stt.stop();
    _audioPlayer.dispose();
  }
}
