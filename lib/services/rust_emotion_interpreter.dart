import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_config.dart';
import '../../data/model/kurisu_expression.dart';

enum Emotion { happy, angry, sad, neutral, excited, scared, love, surprised, suspicious, proud }

class RustResponse {
  final String text;
  final int? toneScore; // -2..+2
  final List<String>? keywords;
  const RustResponse({required this.text, this.toneScore, this.keywords});
}

class EmotionSnapshot {
  final Emotion emotion;
  final double intensity;
  final DateTime ts;
  const EmotionSnapshot({required this.emotion, required this.intensity, required this.ts});
  Map<String, dynamic> toMap() => {'e': emotion.name, 'i': intensity, 't': ts.toIso8601String()};
  factory EmotionSnapshot.fromMap(Map m) => EmotionSnapshot(
    emotion: Emotion.values.firstWhere((e) => e.name == m['e'], orElse: () => Emotion.neutral),
    intensity: (m['i'] is double) ? m['i'] as double : (m['i'] as num).toDouble(),
    ts: DateTime.tryParse(m['t'] as String) ?? DateTime.now(),
  );
}

class EmotionInterpreter {
  static const _kHistory = 'emotion_history';

  static const _emotionTurkishKeywords = <Emotion, List<String>>{
    Emotion.happy:     ['happy', 'mutlu', 'sevinç', 'güzel', 'teşekkür', 'iyi'],
    Emotion.angry:     ['angry', 'kızgın', 'öfkeli', 'sinirli', 'kızgındım', 'sinir'],
    Emotion.sad:       ['sad', 'üzgün', 'kayıp', 'üzül', 'üzgünüm', 'malesef'],
    Emotion.love:      ['love', 'aşk', 'sevgi', 'gönül', 'kalp'],
    Emotion.scared:    ['scared', 'korkmuş', 'korku', 'ürk', 'korktum'],
    Emotion.proud:     ['proud', 'gururlu', 'mağrur', 'gurur'],
    Emotion.surprised: ['surprise', 'şaşkın', 'sürpriz', 'inanamıyorum'],
    Emotion.suspicious:['sus', 'şüpheli', 'güvenmiyorum', 'şüphe'],
    Emotion.excited:   ['excited', 'heyecanlı', 'enerjik', 'heyecan'],
  };

  static const _toneScoreFallback = <int, Emotion>{
    -2: Emotion.sad,
    -1: Emotion.angry,
    0: Emotion.neutral,
    1: Emotion.happy,
    2: Emotion.excited,
  };

  static const _assetPrefix = <Emotion, String>{
    Emotion.happy:     'CRS_JLD',
    Emotion.angry:     'CRS_JMD',
    Emotion.sad:       'CRS_JSD',
    Emotion.neutral:   'CRS_JSE',
    Emotion.excited:   'CRS_JME',
    Emotion.scared:    'CRS_JSE',
    Emotion.love:      'CRS_JLD',
    Emotion.surprised: 'CRS_JLE',
    Emotion.suspicious:'CRS_JME',
    Emotion.proud:     'CRS_JLD',
  };

  static const _avatarExpression = <Emotion, KurisuExpression>{
    Emotion.happy:     KurisuExpression.happy,
    Emotion.angry:     KurisuExpression.angry,
    Emotion.sad:       KurisuExpression.sad,
    Emotion.neutral:   KurisuExpression.normal,
    Emotion.excited:   KurisuExpression.happy,
    Emotion.scared:    KurisuExpression.sad,
    Emotion.love:      KurisuExpression.blush,
    Emotion.surprised: KurisuExpression.happy,
    Emotion.suspicious:KurisuExpression.thinking,
    Emotion.proud:     KurisuExpression.normal,
  };

  static const _voiceBanks = <Emotion, List<String>>{
    Emotion.happy:     ['happy', 'joy'],
    Emotion.angry:     ['angry', 'mad'],
    Emotion.sad:       ['sad', 'disappoint'],
    Emotion.neutral:   ['neutral'],
    Emotion.excited:   ['excited', 'energ'],
    Emotion.scared:    ['scared', 'fear'],
    Emotion.love:      ['love', 'blush'],
    Emotion.surprised: ['surprise', 'excited'],
    Emotion.suspicious:['thinking', 'neutral'],
    Emotion.proud:     ['proud', 'happy'],
  };

  EmotionInterpreter._();

  static Emotion classify(RustResponse r) {
    final keywords = (r.keywords ?? []).map((e) => e.toLowerCase()).toList();
    for (final entry in _emotionTurkishKeywords.entries) {
      final match = entry.value.where(keywords.contains);
      if (match.isNotEmpty) return entry.key;
    }
    return _toneScoreFallback[r.toneScore] ?? Emotion.neutral;
  }

  static ({Emotion emotion, double intensity}) classifyWithIntensity(RustResponse r) {
    final emotion = classify(r);
    final toneFactor = ((r.toneScore?.abs() ?? 0) / 2.0).clamp(0.0, 1.0);
    final lenFactor = (r.text.length / 200.0).clamp(0.0, 1.0);
    final intensity = (toneFactor * 0.6 + lenFactor * 0.4).clamp(0.15, 1.0);
    return (emotion: emotion, intensity: intensity);
  }

  static String assetPrefixFor(Emotion e) => _assetPrefix[e] ?? 'CRS_JSE';

  static KurisuExpression avatarExpressionFor(Emotion e) => _avatarExpression[e] ?? KurisuExpression.normal;

  static List<String> voiceBankFor(Emotion e) => _voiceBanks[e] ?? ['neutral'];

  static void triggerHaptic(Emotion e, double intensity) {
    if (e != Emotion.angry) return;
    if (intensity <= 0.35) {
      HapticFeedback.lightImpact();
    } else if (intensity <= 0.7) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  static Future<void> addSnapshot(Emotion e, double intensity) async {
    final p = await SharedPreferences.getInstance();
    final list = _load(p);
    list.add(EmotionSnapshot(emotion: e, intensity: intensity, ts: DateTime.now()).toMap());
    if (list.length > 200) list.removeRange(0, list.length - 200);
    await p.setString(_kHistory, jsonEncode(list));
  }

  static Future<List<EmotionSnapshot>> recent({int n = 10}) async {
    final p = await SharedPreferences.getInstance();
    final all = _load(p).map(EmotionSnapshot.fromMap).toList();
    return all.reversed.take(n).toList();
  }

  static Future<Emotion> dominant({int window = 20}) async {
    final r = await recent(n: window);
    if (r.isEmpty) return Emotion.neutral;
    final counts = <Emotion, int>{};
    for (final s in r) counts[s.emotion] = (counts[s.emotion] ?? 0) + 1;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static Future<List<String>> candidateVoiceFiles(Emotion e) async {
    final prefix = assetPrefixFor(e);
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> decoded = jsonDecode(manifest);
      final candidates = decoded.keys.where((k) {
        final name = k.split('/').last;
        final stem = name.split('.').first;
        final lower = stem.toLowerCase();
        return lower.startsWith(prefix.toLowerCase()) ||
            voiceBankFor(e).any((v) => lower.contains(v));
      }).toList();
      return candidates;
    } on Exception {
      return ['assets/voices/oneshot/${prefix.toLowerCase()}_default.wav'];
    }
  }

  static List<Map<String, dynamic>> _load(SharedPreferences p) {
    final raw = p.getString(_kHistory);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Emotion modulateForMusic(String musicGenre) {
    final lower = musicGenre.toLowerCase();
    final aggressive = lower.contains('metal') ||
        lower.contains('rock') ||
        lower.contains('hardcore') ||
        lower.contains('punk') ||
        lower.contains('death');
    final classical = lower.contains('classical') ||
        lower.contains('klasik') ||
        lower.contains('barok') ||
        lower.contains('senfon') ||
        lower.contains('piyano') ||
        lower.contains('viyola') ||
        lower.contains('orkestra');
    if (aggressive) return Emotion.excited;
    if (classical) return Emotion.neutral;
    return Emotion.neutral;
  }
}
