import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/model/amadeus_ui_state.dart';
import '../../data/model/personality_type.dart';
import '../viewmodel/amadeus_view_model.dart';
import '../theme/app_theme.dart';
import '../widgets/kurisu_avatar.dart';
import '../widgets/music_player.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.viewModel, required this.onSwitchPersonality});

  final AmadeusViewModel viewModel;
  final void Function(PersonalityType type) onSwitchPersonality;

  static const List<Map<String, dynamic>> defaultPlaylist = [
    {'title': 'CRS IT Long', 'artist': 'Kurisu', 'path': 'assets/voices/oneshot/CRS_IT_LONG.mp3'},
    {'title': 'CRS IT Wave', 'artist': 'Kurisu', 'path': 'assets/voices/oneshot/CRS_IT.wav'},
    {'title': 'CRS EN', 'artist': 'Kurisu', 'path': 'assets/voices/oneshot/CRS_EN.wav'},
    {'title': 'CRS JP', 'artist': 'Kurisu', 'path': 'assets/voices/oneshot/CRS_JP.wav'},
  ];

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.viewModel.uiState;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Row(
          children: [
            // Sol taraftaki konuşma alanı + altında müzik çalı
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  // Konuşma alanı
                  _chatArea(s),
                  const SizedBox(height: 8),
                  // Müzik çalı
                  _playerPanel(s, isMobile),
                ],
              ),
            ),
            // Sağ taraftaki KURISU karakter
            Expanded(
              flex: 3,
              child: _characterPanel(s, isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatArea(AmadeusUiState s) => Expanded(
    flex: 4,
    child: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _LabGridPainter())),
        Column(children: [
          const SizedBox(height: 2),
          _dialoguePanel('', s),
          const SizedBox(height: 8),
          _inputBar(s),
        ]),
      ],
    ),
  );

  Widget _characterPanel(AmadeusUiState s, bool isMobile) => Expanded(
    flex: 3,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KURISU VÜCUDU (tam vücut)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: KurisuAvatar(
              size: 180,
              asset: 'assets/frames_fullbody/CRS_kurisu_fullbody_001.png',
              isSpeaking: s.isSpeaking,
              isThinking: s.isThinking,
              intensity: s.personalityIntensity,
            ),
          ),
          const SizedBox(height: 8),
          // KURISU Yazısı + Sohbet Alanı
          Expanded(
            child: Column(
              children: [
                _dialogueHeader(s),
                Expanded(
                  child: _dialoguePanel(s.isThinking ? 'ANALYZING...' : s.isListening ? 'LISTENING...' : s.streamingResponse, s),
                ),
                _inputBar(s),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _playerPanel(AmadeusUiState s, bool isMobile) => Expanded(
    flex: 1,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgDeep,
        border: Border(left: BorderSide(color: AppTheme.borderColor, width: 2)),
      ),
      child: KurisuMusicPlayer(
        songs: s.musicSongs.isNotEmpty ? s.musicSongs : ChatScreen.defaultPlaylist,
        isPlaying: s.isMusicPlaying,
        currentIndex: s.currentMusicIndex,
        volume: s.musicVolume,
        isMobile: isMobile,
        onPlay: () => widget.viewModel.toggleMusic(),
        onStop: () => widget.viewModel.stopMusic(),
        onNext: () => widget.viewModel.nextMusic(),
        onPrev: () => widget.viewModel.prevMusic(),
        onSongChanged: (int idx) => widget.viewModel.setPlaylistIndex(idx),
      ),
    ),
  );

  Widget _dialoguePanel(String text, AmadeusUiState s) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: BoxDecoration(
      color: AppTheme.bgChat,
      border: Border.all(color: AppTheme.borderColor),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 20, height: 20, decoration: BoxDecoration(color: AppTheme.accentRed.withValues(alpha: 0.15), shape: BoxShape.circle)),
        const SizedBox(width: 10),
        const Text('KURISU', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(s.isThinking ? 'PROCESSING' : s.isSpeaking ? 'SPEAKING' : 'READY', style: TextStyle(color: AppTheme.textSecondary, fontSize: 8, letterSpacing: 1.2)),
        const SizedBox(width: 8),
        Container(width: 6, height: 6, decoration: BoxDecoration(color: s.isThinking ? AppTheme.accentAmber : (s.isSpeaking ? AppTheme.accentRed : AppTheme.textTertiary), shape: BoxShape.circle)),
      ]),
      const SizedBox(height: 10),
      Text(text, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.5)),
      if (s.isSpeaking)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: widget.viewModel.stopAudio,
            icon: const Icon(Icons.stop_circle_outlined, size: 16, color: AppTheme.accentRed),
            label: const Text('Sesi durdur', style: TextStyle(color: AppTheme.accentRed, fontSize: 9, letterSpacing: 1)),
          ),
        ),
    ]),
  );

  Widget _dialogueHeader(AmadeusUiState s) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
        const Text('KURISU', style: TextStyle(color: AppTheme.textSecondary, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(s.isThinking ? 'ANALYZING' : s.isListening ? 'LISTENING' : s.isSpeaking ? 'SPEAKING' : 'READY', style: TextStyle(color: AppTheme.textSecondary, fontSize: 8, letterSpacing: 1.2)),
        const SizedBox(width: 4),
        Container(width: 6, height: 6, decoration: BoxDecoration(color: s.isThinking ? AppTheme.accentAmber : (s.isSpeaking ? AppTheme.accentRed : AppTheme.textTertiary), shape: BoxShape.circle)),
      ],
    ),
  );

  Widget _inputBar(AmadeusUiState s) => Container(
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
    decoration: const BoxDecoration(
      color: AppTheme.bgChat,
      border: Border(top: BorderSide(color: AppTheme.borderColor)),
    ),
    child: Row(children: [
      IconButton(onPressed: widget.viewModel.toggleListening, icon: Icon(s.isListening ? Icons.mic : Icons.mic_none, color: s.isListening ? AppTheme.accentRed : AppTheme.textTertiary), splashRadius: 20),
      Expanded(
        child: TextField(
          controller: _controller,
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _send(),
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Kurisu ile konuş…',
            hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
            filled: true,
            fillColor: AppTheme.bgChat,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ),
      const SizedBox(width: 8),
      IconButton(onPressed: _send, icon: const Icon(Icons.arrow_upward_rounded, color: AppTheme.accentRed), splashRadius: 20),
    ]),
  );

  void _send() {
    final t = _controller.text;
    if (t.trim().isEmpty) return;
    _controller.clear();
    widget.viewModel.sendMessage(t, null);
  }
}

class _LabGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppTheme.bgDeep.withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Halka başlangıç rengi (kırmızı/amber)
    final accent = Paint()
      ..color = AppTheme.accentRed.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Yatay damarlar
    final yy = <double>[
      0.0,
      size.height * 0.15,
      size.height * 0.45,
      size.height * 0.75,
    ];
    // Dikey damarlar
    final xx = <double>[
      0.0,
      size.width * 0.12,
      size.width * 0.38,
      size.width * 0.70,
      size.width * 0.95,
    ];

    for (final y in yy) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), accent);
    }
    for (final x in xx) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), accent);
    }

    // Genel ızgara (ince çizgiler)
    final grid = Paint()
      ..color = AppTheme.accentRed.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Merkez çizgileri (başlık çizgisi - KURISU çizgisi)
    final mid = Paint()
      ..color = AppTheme.accentRed.withValues(alpha: 0.25)
      ..strokeWidth = 3;
    canvas.drawLine(const Offset(18, 18), const Offset(42, 18), mid);
    canvas.drawLine(const Offset(18, 18), const Offset(18, 42), mid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
