import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/memory_data.dart';

/// Hafıza JSON verisini Android Keystore destekli güvenli depoda saklar.
class MemoryManager {
  MemoryManager(this._storage);
  final FlutterSecureStorage _storage;
  static const String _key = 'amadeus_memory_v2';

  static Future<MemoryManager> load() async {
    final manager = MemoryManager(const FlutterSecureStorage());
    await manager._ensureLoaded();
    // Önceki sürümdeki düz SharedPreferences hafızasını güvenli alana taşı.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString('memory_data');
    var migrated = false;
    if (manager._cache.isEmpty && legacy != null && legacy.isNotEmpty) {
      try {
        final list = jsonDecode(legacy) as List<dynamic>;
        manager._cache = list.map((e) => MemoryData.fromJson(e as Map<String, dynamic>)).toList();
        await manager._persist();
        migrated = true;
      } catch (_) {}
    } else if (legacy == null || legacy.isEmpty) {
      migrated = true;
    }
    if (migrated) await prefs.remove('memory_data');
    return manager;
  }

  List<MemoryData> _cache = <MemoryData>[];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final raw = await _storage.read(key: _key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _cache = list.map((e) => MemoryData.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) { _cache = <MemoryData>[]; }
    }
    _loaded = true;
  }

  // UI'nin senkron okuyucularıyla uyumlu: load() öncesi çağrılmamalıdır.
  List<MemoryData> getMemories() => List<MemoryData>.of(_cache);

  Future<void> saveMemory(MemoryData memory) async {
    await _ensureLoaded();
    _cache.removeWhere((m) => m.id == memory.id || m.content.toLowerCase() == memory.content.toLowerCase());
    _cache.add(memory);
    _cache.sort((a, b) => b.importance.compareTo(a.importance));
    if (_cache.length > 500) _cache = _cache.take(500).toList();
    await _persist();
  }

  /// Basit anahtar-kelime araması; çevrim dışı çalışır ve yeni model çağrısı yapmaz.
  List<MemoryData> searchMemories(String query, {int limit = 20}) {
    final terms = query.toLowerCase().split(RegExp(r'[^\p{L}\p{N}]+', unicode: true)).where((e) => e.length > 1).toSet();
    if (terms.isEmpty) return const <MemoryData>[];
    final ranked = _cache.map((memory) {
      final text = memory.content.toLowerCase();
      final score = terms.where(text.contains).length + memory.importance * 0.25;
      return (memory: memory, score: score);
    }).where((item) => item.score > 0).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return ranked.take(limit).map((e) => e.memory).toList();
  }

  /// Açık hatırlatma/tercih ifadelerini otomatik hafızaya alır.
  /// Genel sohbeti topluca kaydetmez; yalnızca açık işaretleyiciler kullanılır.
  Future<void> rememberExplicitUserStatement(String text) async {
    final value = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (value.length < 8 || value.length > 500) return;
    final lower = value.toLowerCase();
    const markers = ['hatırla', 'unutma', 'tercihim', 'tercih ederim', 'projem', 'hedefim'];
    if (!markers.any(lower.contains)) return;
    final memory = MemoryData(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: value,
      timestamp: DateTime.now(),
      importance: lower.contains('hatırla') || lower.contains('unutma') ? 0.95 : 0.75,
    );
    await saveMemory(memory);
  }

  Future<void> saveMemories(List<MemoryData> memories) async {
    await _ensureLoaded(); _cache = List<MemoryData>.of(memories); await _persist();
  }
  Future<void> deleteMemory(String id) async {
    await _ensureLoaded(); _cache.removeWhere((m) => m.id == id); await _persist();
  }
  Future<void> clearAll() async { _cache.clear(); _loaded = true; await _storage.delete(key: _key); }
  Future<void> _persist() => _storage.write(key: _key, value: jsonEncode(_cache.map((m) => m.toJson()).toList()));
}
