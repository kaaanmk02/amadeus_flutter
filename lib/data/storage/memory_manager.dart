import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/memory_data.dart';

/// Hafıza kayıtlarını `shared_preferences` içinde JSON listesi olarak saklar.
/// `MemoryManager.java` ile aynı saklama yaklaşımı.
class MemoryManager {
  MemoryManager(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'memory_data';

  static Future<MemoryManager> load() async =>
      MemoryManager(await SharedPreferences.getInstance());

  List<MemoryData> getMemories() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <MemoryData>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MemoryData.fromJson(e as Map<String, dynamic>))
          .toList(growable: true);
    } catch (_) {
      return <MemoryData>[];
    }
  }

  Future<void> saveMemory(MemoryData memory) async {
    final all = getMemories();
    all.removeWhere((m) => m.id == memory.id);
    all.add(memory);
    await _persist(all);
  }

  Future<void> saveMemories(List<MemoryData> memories) => _persist(memories);

  Future<void> deleteMemory(String id) async {
    final all = getMemories()..removeWhere((m) => m.id == id);
    await _persist(all);
  }

  Future<void> clearAll() => _prefs.remove(_key);

  Future<void> _persist(List<MemoryData> memories) => _prefs.setString(
      _key, jsonEncode(memories.map((m) => m.toJson()).toList()));
}
