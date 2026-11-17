import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/chat_message.dart';

/// Şifreli oturum arşivi ve kompakt bağlam devri.
class SessionManager {
  SessionManager(this._storage);
  final FlutterSecureStorage _storage;
  static const _key = 'amadeus_sessions_v2';
  static const _activeKey = 'amadeus_active_session_v2';
  static const _activeMessagesKey = 'amadeus_active_messages_v2';
  static const int maxArchiveSessions = 100;
  final List<Map<String, dynamic>> _sessions = [];
  String _activeId = '';
  String _carrySummary = '';
  final List<ChatMessage> _activeMessages = <ChatMessage>[];
  Future<void> _saveQueue = Future<void>.value();

  static Future<SessionManager> load() async {
    final manager = SessionManager(const FlutterSecureStorage());
    final raw = await manager._storage.read(key: _key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          manager._sessions.addAll(decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
        }
      } catch (_) { /* bozuk arşiv uygulamanın açılmasını engellemez */ }
    }
    manager._sortNewest(manager._sessions);
    manager._activeId = await manager._storage.read(key: _activeKey) ?? '';
    final activeRaw = await manager._storage.read(key: _activeMessagesKey);
    if (activeRaw != null && activeRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(activeRaw);
        if (decoded is List) {
          manager._activeMessages.addAll(decoded.whereType<Map>().map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e))));
        }
      } catch (_) { /* corrupted active history is safely ignored */ }
    }
    if (manager._activeId.isEmpty) manager._activeId = DateTime.now().microsecondsSinceEpoch.toString();
    if (manager._sessions.isNotEmpty) {
      manager._carrySummary = manager._sessions.first['summary']?.toString() ?? '';
    }
    await manager._storage.write(key: _activeKey, value: manager._activeId);
    return manager;
  }

  String get carrySummary => _carrySummary;
  String get activeSessionId => _activeId;
  List<Map<String, dynamic>> get sessions => List.unmodifiable(_sessions);
  List<ChatMessage> get activeMessages => List<ChatMessage>.unmodifiable(_activeMessages);

  Future<void> saveActiveMessages(List<ChatMessage> messages) {
    _activeMessages
      ..clear()
      ..addAll(messages.map((m) => ChatMessage(role: m.role, content: m.content, timestamp: m.timestamp)));
    // Images are intentionally excluded to avoid filling secure storage with base64.
    final snapshot = jsonEncode(_activeMessages.map((m) => m.toJson()).toList());
    _saveQueue = _saveQueue.then((_) => _storage.write(key: _activeMessagesKey, value: snapshot));
    return _saveQueue;
  }

  List<Map<String, dynamic>> searchSessions(String query, {int limit = 5}) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _sessions.take(limit).toList();
    final terms = q.split(RegExp(r'[^\p{L}\p{N}]+', unicode: true)).where((e) => e.length > 1).toSet();
    final ranked = _sessions.map((s) {
      final text = ('${s['summary'] ?? ''}').toLowerCase();
      final score = terms.where(text.contains).length;
      return (session: s, score: score);
    }).where((e) => e.score > 0).toList()..sort((a, b) => b.score.compareTo(a.score));
    return ranked.take(limit).map((e) => e.session).toList();
  }

  /// Kısa, çıkarımsal özet: son konuşma akışını korur, devreden özeti sınırlar.
  String summarize(List<ChatMessage> messages, {int maxChars = 2400}) {
    final userFacts = <String>[];
    final decisions = <String>[];
    final recent = <String>[];
    for (final m in messages) {
      final text = m.content.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty || m.imageBase64 != null) continue;
      final clipped = text.length > 420 ? '${text.substring(0, 417)}...' : text;
      if (m.role == 'user') {
        recent.add('Kullanıcı: $clipped');
        final lower = text.toLowerCase();
        if (RegExp(r'\b(benim|bana|tercihim|istiyorum|projem|kullanıyorum|hedefim)\b').hasMatch(lower)) {
          userFacts.add('Kullanıcı bilgisi/tercihi: $clipped');
        }
      } else {
        recent.add('Amadeus: $clipped');
        final lower = text.toLowerCase();
        if (RegExp(r'\b(yapacağız|kararlaştırdık|eklendi|tamamlandı|öncelik)\b').hasMatch(lower)) {
          decisions.add('Karar/ilerleme: $clipped');
        }
      }
    }
    final tail = recent.length > 10 ? recent.sublist(recent.length - 10) : recent;
    final sections = <String>[
      if (userFacts.isNotEmpty) 'KALICI OLABİLECEK KULLANICI BİLGİLERİ:\n${userFacts.toSet().take(5).join('\n')}',
      if (decisions.isNotEmpty) 'PROJE KARARLARI:\n${decisions.toSet().take(5).join('\n')}',
      if (tail.isNotEmpty) 'SON KONUŞMA:\n${tail.join('\n')}',
    ];
    var summary = sections.join('\n\n');
    if (summary.length > maxChars) summary = summary.substring(summary.length - maxChars);
    return summary;
  }

  Future<void> closeAndStart(List<ChatMessage> messages, {String? summaryOverride}) async {
    await _saveQueue;
    final current = (summaryOverride ?? '').trim().isNotEmpty
        ? summaryOverride!.trim()
        : summarize(messages);
    final merged = [
      if (_carrySummary.isNotEmpty) 'ÖNCEKİ OTURUMLARDAN DEVREDEN BAĞLAM:\n$_carrySummary',
      if (current.isNotEmpty) 'KAPATILAN OTURUM:\n$current',
    ].join('\n\n');
    final compact = _compact(merged, 3000);
    if (compact.isNotEmpty) {
      _sessions.insert(0, {
        'id': _activeId,
        'closedAt': DateTime.now().toUtc().toIso8601String(),
        'summary': compact,
        'messageCount': messages.length,
      });
      if (_sessions.length > maxArchiveSessions) _sessions.removeRange(maxArchiveSessions, _sessions.length);
      _carrySummary = compact;
    }
    _activeId = DateTime.now().microsecondsSinceEpoch.toString();
    _activeMessages.clear();
    await _storage.delete(key: _activeMessagesKey);
    await _persist();
    await _storage.write(key: _activeKey, value: _activeId);
  }

  String _compact(String value, int limit) => value.length <= limit ? value : value.substring(value.length - limit);
  Future<void> _persist() async => _storage.write(key: _key, value: jsonEncode(_sessions));
  void _sortNewest(List<Map<String, dynamic>> items) {
    items.sort((a, b) => (b['closedAt'] ?? '').toString().compareTo((a['closedAt'] ?? '').toString()));
  }
}
