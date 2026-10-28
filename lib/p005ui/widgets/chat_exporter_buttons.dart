import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/model/chat_message.dart';
import '../../data/storage/chat_exporter.dart';
import '../../core/amadeus_assets.dart';
import '../theme/app_theme.dart';

class ChatExporterButtons extends StatelessWidget {
  const ChatExporterButtons({super.key, required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => _export(context, messages, 'txt'),
          icon: const Icon(Icons.text_snippet, size: 18, color: AppTheme.accentAmber),
          label: const Text('TXT', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ),
        TextButton.icon(
          onPressed: () => _export(context, messages, 'json'),
          icon: const Icon(Icons.code, size: 18, color: AppTheme.accentAmber),
          label: const Text('JSON', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, List<ChatMessage> messages, String type) async {
    try {
      final exporter = ChatExporter();
      final date = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${AmadeusAssets.chatExportBase}/amadeus_$date.$type';
      String? result;
      if (type == 'txt') {
        result = await exporter.exportTxt(messages, filePath: path);
      } else {
        result = await exporter.exportJson(messages, filePath: path);
      }
      if (result != null && context.mounted) {
        await Clipboard.setData(ClipboardData(text: 'Kaydedildi: $result'));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dışa aktarıldı: $result'), backgroundColor: AppTheme.accentGreen),
          );
        }
      }
    } on Exception catch (_) {}
  }
}
