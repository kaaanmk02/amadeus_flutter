import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/chat_message.dart';
import '../storage/settings_manager.dart';

class ChatExporter {
  ChatExporter(this.settings);
  final SettingsManager settings;

  Future<String?> exportTxt(List<ChatMessage> messages) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Amadeus Sohbet Arşivi');
      buffer.writeln('Tarih: ${DateTime.now()}');
      buffer.writeln('---');
      for (final m in messages) {
        final time = m.timestamp != null ? ' [${m.timestamp}]' : '';
        buffer.writeln('${m.role.toUpperCase()}$time: ${m.content}');
      }
      return await _write(buffer.toString(), 'amadeus_chat.txt');
    } on Exception catch (_) {
      return null;
    }
  }

  Future<String?> exportJson(List<ChatMessage> messages) async {
    try {
      final data = messages.map((m) => m.toJson()).toList();
      final json = const JsonEncoder.withIndent('  ').convert(data);
      return await _write(json, 'amadeus_chat.json');
    } on Exception catch (_) {
      return null;
    }
  }

  Future<String?> _write(String content, String fileName) async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) return null;
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }
}
