import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/model/amadeus_ui_state.dart';
import '../../data/model/chat_message.dart';
import 'memory_log_screen.dart';
import '../../data/model/personality_type.dart';
import '../../p005ui/viewmodel/amadeus_view_model.dart';
import '../theme/app_theme.dart';
import '../widgets/kurisu_avatar.dart';
import '../widgets/chat_exporter_buttons.dart';
import 'settings_sheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.viewModel, required this.onSwitchPersonality});
  final AmadeusViewModel viewModel;
  final void Function(PersonalityType type) onSwitchPersonality;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _showHistory = true;
  @override
  void dispose() { _controller.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.viewModel.uiState;
    final latest = s.streamingResponse.isNotEmpty ? s.streamingResponse : _latestAssistant(s.messages);
    return Scaffold(backgroundColor: AppTheme.bgDeep, body: SafeArea(child: Column(children: [
      _topBar(s),
      Expanded(flex: 6, child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _LabGridPainter())),
        Column(children: [
          const SizedBox(height: 2),
          Expanded(child: Center(child: KurisuAvatar(expression: s.currentExpression, size: _avatarSize(context), isSpeaking: s.isSpeaking, isThinking: s.isThinking, intensity: s.expressionIntensity))),
          _characterStatus(s),
          const SizedBox(height: 8),
          _dialoguePanel(latest, s),
        ]),
      ])),
      _historyToggle(s),
      if (_showHistory) Expanded(flex: 3, child: _history(s)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: ChatExporterButtons(messages: s.messages)),
      _inputBar(s),
    ])));
  }

  double _avatarSize(BuildContext c) => (MediaQuery.of(c).size.height * .20).clamp(150.0, 205.0).toDouble();
  String _latestAssistant(List<ChatMessage> messages) {
    for (final m in messages.reversed) { if (m.role == 'assistant') return m.content; }
    return 'Bağlantı kuruldu. Söyleyecek bir şeyin mi var?';
  }
  Widget _topBar(AmadeusUiState s) => Container(height: 54, padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: const BoxDecoration(color: Color(0xFF101117), border: Border(bottom: BorderSide(color: Color(0xFF34313A)))),
    child: Row(children: [
      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFB33B45), shape: BoxShape.circle)),
      const SizedBox(width: 9), const Text('AMΔDEUS', style: TextStyle(color: Color(0xFFE6D9D1), letterSpacing: 2.2, fontWeight: FontWeight.w700)),
      const SizedBox(width: 8), const Text('LAB. 未来ガジェット研究所', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
      const Spacer(),
      if (s.divergenceMeter != null) Text('D ${s.divergenceMeter}', style: const TextStyle(color: AppTheme.accentAmber, fontSize: 10, fontFamily: 'monospace')),
      IconButton(tooltip: 'Oturum arşivi', visualDensity: VisualDensity.compact, onPressed: _openSessions, icon: const Icon(Icons.history, color: Color(0xFFD5A6A1), size: 19)),
      IconButton(tooltip: 'Hafıza kayıtları', visualDensity: VisualDensity.compact, onPressed: _openMemories, icon: const Icon(Icons.memory, color: Color(0xFFD5A6A1), size: 19)),
      IconButton(tooltip: 'Ayarlar', visualDensity: VisualDensity.compact, onPressed: _openSettings, icon: const Icon(Icons.tune, color: Color(0xFFD5A6A1), size: 20)),
    ]));

  Widget _characterStatus(AmadeusUiState s) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
    Container(width: 1, height: 30, color: const Color(0xFFB33B45)), const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('牧瀬 紅莉栖', style: TextStyle(color: Color(0xFFF0E8E3), fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1)),
      Text(s.isThinking ? 'ANALYZING / 考え中' : s.isListening ? 'LISTENING / 聞いています' : 'ONLINE  •  ${s.currentPersonality.name.toUpperCase()}', style: const TextStyle(color: Color(0xFFB66B70), fontSize: 9, letterSpacing: 1.4)),
    ]), const Spacer(),
    Text('${(s.personalityIntensity * 100).round()}%', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontFamily: 'monospace')),
  ]));

  Widget _dialoguePanel(String text, AmadeusUiState s) => Container(width: double.infinity, margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
    padding: const EdgeInsets.fromLTRB(15, 11, 15, 13),
    decoration: BoxDecoration(color: const Color(0xE916171D), border: Border.all(color: const Color(0xFF49343A)), borderRadius: BorderRadius.circular(3),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 56), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('KURISU', style: TextStyle(color: Color(0xFFCF777C), fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)), const Spacer(),
        Text(s.isThinking ? 'PROCESSING' : s.isSpeaking ? 'SPEAKING' : 'READY', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 8, letterSpacing: 1.2))]),
      const SizedBox(height: 7), Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFE9E2DE), fontSize: 14, height: 1.45)),
      if (s.isSpeaking) Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: widget.viewModel.stopAudio, icon: const Icon(Icons.stop_circle_outlined, size: 16), label: const Text('Sesi durdur'), style: TextButton.styleFrom(foregroundColor: AppTheme.accentAmber))),
    ]));

  Widget _historyToggle(AmadeusUiState s) => InkWell(onTap: () => setState(() => _showHistory = !_showHistory), child: Padding(padding: const EdgeInsets.fromLTRB(16, 3, 16, 5), child: Row(children: [
    const Text('COMMUNICATION LOG', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9, letterSpacing: 1.5)), const SizedBox(width: 6),
    Text('${s.messages.length}', style: const TextStyle(color: Color(0xFFB66B70), fontSize: 9)), const Spacer(),
    Icon(_showHistory ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 16, color: AppTheme.textSecondary),
  ])));

  Widget _history(AmadeusUiState s) => ListView.builder(controller: _scroll, padding: const EdgeInsets.fromLTRB(14, 0, 14, 6), itemCount: s.messages.length + (s.isThinking ? 1 : 0), itemBuilder: (context, i) {
    if (s.isThinking && i == s.messages.length) return const _LogLine(label: 'AMADEUS', content: 'Yanıt hazırlanıyor…', assistant: true);
    final m = s.messages[i]; return _LogLine(label: m.role == 'user' ? 'YOU' : 'KURISU', content: m.content, assistant: m.role != 'user');
  });

  Widget _inputBar(AmadeusUiState s) => Container(padding: const EdgeInsets.fromLTRB(5, 7, 9, 7), decoration: const BoxDecoration(color: Color(0xFF111218), border: Border(top: BorderSide(color: Color(0xFF393138)))), child: Row(children: [
    PopupMenuButton<ImageSource>(tooltip: 'Görsel ekle', icon: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFB66B70)), onSelected: _pickImage, itemBuilder: (_) => const [PopupMenuItem(value: ImageSource.camera, child: Row(children: [Icon(Icons.camera_alt_outlined), SizedBox(width: 10), Text('Kamerayı aç')])), PopupMenuItem(value: ImageSource.gallery, child: Row(children: [Icon(Icons.photo_library_outlined), SizedBox(width: 10), Text('Galeriden seç')]))]),
    IconButton(onPressed: widget.viewModel.toggleListening, icon: Icon(s.isListening ? Icons.mic : Icons.mic_none, color: s.isListening ? AppTheme.accentRed : const Color(0xFFB66B70))),
    Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 3, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14), decoration: InputDecoration(hintText: 'Kurisu ile konuş…', hintStyle: const TextStyle(color: Color(0xFF77727A), fontSize: 13), filled: true, fillColor: const Color(0xFF1B1B22), contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11), border: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide.none)))),
    const SizedBox(width: 6), IconButton(onPressed: _send, icon: const Icon(Icons.arrow_upward_rounded, color: Color(0xFFE4B5AE))),
  ]));
  void _send() { final t = _controller.text; if (t.trim().isEmpty) return; _controller.clear(); widget.viewModel.sendMessage(t, null); }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 78, maxWidth: 1440);
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;
      await widget.viewModel.sendMessage('Bu görseli analiz et. İçeriğini ve önemli ayrıntıları açıkla.', base64Encode(bytes));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Görsel açılamadı: $error')));
    }
  }

  void _openSessions() {
    final sessions = widget.viewModel.archivedSessions;
    showModalBottomSheet<void>(
      context: context, backgroundColor: AppTheme.bgDeep, isScrollControlled: true,
      builder: (sheetContext) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Expanded(child: Text('OTURUM ARŞİVİ', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.4))), TextButton.icon(onPressed: () async { Navigator.pop(sheetContext); await widget.viewModel.startNewSession(); }, icon: const Icon(Icons.add), label: const Text('Yeni oturum'))]),
          const SizedBox(height: 8),
          const Text('Oturumlar kısa özet olarak saklanır; yeni oturum açmak mevcut bağlamı sıfırlamaz.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 8),
          if (sessions.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Henüz arşivlenmiş oturum yok.', style: TextStyle(color: AppTheme.textSecondary))),
          SizedBox(height: MediaQuery.of(context).size.height * .55, child: ListView.builder(shrinkWrap: true, itemCount: sessions.length, itemBuilder: (_, i) {
            final session = sessions[i];
            final summary = (session['summary'] ?? '').toString();
            final date = DateTime.tryParse((session['closedAt'] ?? '').toString());
            return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.bgChat, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF393138))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(date == null ? 'Oturum ${i + 1}' : '${date.toLocal()}', style: const TextStyle(color: AppTheme.accentAmber, fontSize: 11)),
              const SizedBox(height: 5), Text(summary, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
              Text('${session['messageCount'] ?? 0} mesaj', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
            ]));
          })),
        ]),
      )),
    );
  }

  void _openMemories() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MemoryLogScreen(memoryManager: widget.viewModel.repository.memoryManager)));
  }
  void _openSettings() => showModalBottomSheet(context: context, backgroundColor: AppTheme.bgDeep, isScrollControlled: true, builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: SettingsSheet(viewModel: widget.viewModel)));
}

class _LogLine extends StatelessWidget {
  const _LogLine({required this.label, required this.content, required this.assistant});
  final String label, content; final bool assistant;
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 5), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFF14151B), border: Border(left: BorderSide(color: assistant ? const Color(0xFF9B555B) : const Color(0xFF777D83), width: 2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: assistant ? const Color(0xFFCB8588) : const Color(0xFF9BA5AC), fontSize: 8, letterSpacing: 1.5)), const SizedBox(height: 3), Text(content, style: const TextStyle(color: Color(0xFFD8D5D2), fontSize: 12, height: 1.35))]));
}

class _LabGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF8D6870).withValues(alpha: 0.07)..strokeWidth = .5;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    final line = Paint()..color = const Color(0xFFB66B70).withValues(alpha: 41)..strokeWidth = 1;
    canvas.drawLine(const Offset(12, 12), const Offset(44, 12), line);
    canvas.drawLine(const Offset(12, 12), Offset(12, 44), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
