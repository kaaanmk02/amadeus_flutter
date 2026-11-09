import 'package:flutter/material.dart';
import '../../data/model/memory_data.dart';
import '../theme/app_theme.dart';

class MemoryLogScreen extends StatelessWidget {
  const MemoryLogScreen({required this.memories, super.key});

  final List<MemoryData> memories;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgDeep,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hafıza Kayıtları', style: TextStyle(color: AppTheme.accentAmber, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Expanded(
            child: memories.isEmpty
                ? const Center(child: Text('Kayıt yok.', style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.builder(
                    itemCount: memories.length,
                    itemBuilder: (_, i) {
                      final m = memories[i];
                      return _Tile(title: m.title, body: m.content, date: m.updatedAt);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.body, required this.date});
  final String title;
  final String body;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: AppTheme.bgChat, borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text(date.toIso8601String().substring(0, 19), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }
}
