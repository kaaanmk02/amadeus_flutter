import 'package:flutter/material.dart';
import '../../data/model/memory_data.dart';
import '../../data/storage/memory_manager.dart';
import '../theme/app_theme.dart';

class MemoryLogScreen extends StatefulWidget {
  const MemoryLogScreen({required this.memoryManager, super.key});
  final MemoryManager memoryManager;
  @override
  State<MemoryLogScreen> createState() => _MemoryLogScreenState();
}
class _MemoryLogScreenState extends State<MemoryLogScreen> {
  late List<MemoryData> _memories;
  @override
  void initState() { super.initState(); _reload(); }
  void _reload() { _memories = widget.memoryManager.getMemories()..sort((a,b) => b.timestamp.compareTo(a.timestamp)); }
  Future<void> _addMemory() async {
    final controller = TextEditingController();
    final content = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(backgroundColor: AppTheme.bgChat, title: const Text('Yeni hafıza kaydı'), content: TextField(controller: controller, autofocus: true, maxLines: 4, style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(hintText: 'Amadeus neyi hatırlasın?')), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')), TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Kaydet'))]));
    controller.dispose();
    if (content == null || content.isEmpty) return;
    final now = DateTime.now();
    await widget.memoryManager.saveMemory(MemoryData(id: now.microsecondsSinceEpoch.toString(), content: content, timestamp: now, importance: .7));
    if (mounted) setState(_reload);
  }
  Future<void> _delete(MemoryData memory) async { await widget.memoryManager.deleteMemory(memory.id); if (mounted) setState(_reload); }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppTheme.bgDeep, appBar: AppBar(backgroundColor: AppTheme.bgChat, title: const Text('AMADEUS MEMORY', style: TextStyle(letterSpacing: 1.5, fontSize: 14)), actions: [IconButton(onPressed: _addMemory, icon: const Icon(Icons.add, color: AppTheme.accentRed))]), body: _memories.isEmpty ? const Center(child: Text('Henüz kaydedilmiş bir anı yok.', style: TextStyle(color: AppTheme.textSecondary))) : ListView.builder(padding: const EdgeInsets.all(14), itemCount: _memories.length, itemBuilder: (_, i) => _Tile(memory: _memories[i], onDelete: () => _delete(_memories[i]))));
}
class _Tile extends StatelessWidget {
  const _Tile({required this.memory, required this.onDelete});
  final MemoryData memory; final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: AppTheme.bgChat, border: Border(left: BorderSide(color: AppTheme.accentRed, width: 2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Text('ÖNEM ${(memory.importance * 100).round()}%', style: const TextStyle(color: AppTheme.accentAmber, fontSize: 9, letterSpacing: 1.2)), const Spacer(), IconButton(visualDensity: VisualDensity.compact, onPressed: onDelete, icon: const Icon(Icons.delete_outline, size: 17, color: AppTheme.textSecondary))]),
    Text(memory.content, style: const TextStyle(color: AppTheme.textPrimary, height: 1.4)),
    const SizedBox(height: 7), Text(memory.timestamp.toLocal().toString().split('.').first, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
  ]));
}
