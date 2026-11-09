import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/amadeus_assets.dart';
import '../../../core/app_config.dart';
import '../../../data/storage/settings_manager.dart';
import '../../../data/tts/fish_audio_tts.dart';

class SpeechManager {
  SpeechManager({SettingsManager? settings})
      : _settings = settings,
        _tts = FlutterTts(),
        _stt = SpeechToText(),
        _audioPlayer = AudioPlayer();

  final SettingsManager? _settings;
  final FlutterTts _tts;
  final SpeechToText _stt;
  final AudioPlayer _audioPlayer;

  bool _sttReady = false;
  bool get isSttReady => _sttReady;

  Future<void> speak(String text) async {
    final provider = _settings?.getTtsProvider() ?? AppConfig.defaultTtsProvider;
    if (provider == AppConfig.onlineTtsProvider) {
      await _speakOnline(text);
    } else {
      await _speakOffline(text);
    }
  }

  Future<void> _speakOffline(String text) async {
    try {
      await _tts.setLanguage('tr-TR');
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
      final apiKey = _settings?.getApiKey() ?? '';
      final bytes = await FishAudioTts().synthesize(
        text: text,
        apiKey: apiKey == '[REDACTED]' ? null : apiKey,
      );
      if (bytes == null) {
        await _speakOffline(text);
        return;
      }
      final dir = await Directory.systemTemp.createTemp('amadeus_tts_');
      final file = File('${dir.path}/tts.wav');
      await file.writeAsBytes(bytes, flush: true);
      await _audioPlayer.play(DeviceFileSource(file.path));
    } catch (_) {
      await _speakOffline(text);
    }
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
        if (result.recognizedWords.isNotEmpty) onResult(result.recognizedWords);
      },
      localeId: 'tr_TR',
    );
    return true;
  }

  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  void dispose() {
    _tts.stop();
    _stt.stop();
    _audioPlayer.dispose();
  }
}
