import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/chat_message.dart';



class ChatExporter {
  ChatExporter();
  Future<String?> exportTxt(List<ChatMessage> messages, {String filePath = 'amadeus_chat.txt'}) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Amadeus Sohbet Arşivi');
      buffer.writeln('Tarih: ${DateTime.now()}');
      buffer.writeln('---');
      for (final m in messages) {
        final time = m.timestamp != null ? ' [${m.timestamp}]' : '';
        buffer.writeln('${m.role.toUpperCase()}$time: ${m.content}');
      }
      return await _write(buffer.toString(), filePath);
    } on Exception catch (_) {
      return null;
    }
  }
  Future<String?> exportJson(List<ChatMessage> messages, {String filePath = 'amadeus_chat.json'}) async {
    try {
      final data = messages.map((m) => m.toJson()).toList();
      final json = const JsonEncoder.withIndent('  ').convert(data);
      return await _write(json, filePath);
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
