import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'data/ai/llama_gguf_service.dart';
import 'data/ai/local_llm_manager.dart';
import 'data/audio/sound_manager.dart';
import 'data/audio/speech_manager.dart';
import 'data/network/llm_api.dart';
import 'data/notification/notification_manager.dart';
import 'data/repository/amadeus_repository.dart';
import 'data/storage/memory_manager.dart';
import 'data/storage/session_manager.dart';
import 'data/storage/settings_manager.dart';
import 'domain/personality_manager.dart';
import 'p005ui/screens/calling_screen.dart';
import 'p005ui/screens/chat_screen.dart';
import 'p005ui/screens/intro_screen.dart';
import 'p005ui/theme/app_theme.dart';
import 'p005ui/viewmodel/amadeus_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // İç bildirim altyapısı (mesaj / hata bildirimleri).
  await NotificationManager.instance.init();
  await NotificationManager.instance.requestPermission();

  // Kalıcı depo + ayarlar.
  final settings = await SettingsManager.load();
  final memoryManager = await MemoryManager.load();
  final sessionManager = await SessionManager.load();

  final repository = AmadeusRepository(
    api: LlmApi(settings: settings),
    settings: settings,
    personalityManager: const PersonalityManager(),
    memoryManager: memoryManager,
    sessionManager: sessionManager,
  );

  final soundManager = SoundManager();
  final speechManager = SpeechManager(settings: settings);
  final localLlmManager = LocalLlmManager.instance;

  final viewModel = AmadeusViewModel(
    repository: repository,
    soundManager: soundManager,
    speechManager: speechManager,
    localLlmManager: localLlmManager,
    onSpeak: speechManager.speak,
    onExpressionChanged: (_) {},
  );

  runApp(AmadeusApp(viewModel: viewModel, localGgufService: LlamaGgufService.instance));
}

class AmadeusApp extends StatelessWidget {
  const AmadeusApp({
    super.key,
    required this.viewModel,
    required this.localGgufService,
  });

  final AmadeusViewModel viewModel;
  final LlamaGgufService localGgufService;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AMADEUS',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        home: AmadeusRoot(viewModel: viewModel, localGgufService: localGgufService),
      );
}

/// Uygulamanın ekran durum makinesi: intro -> calling -> chat.
class AmadeusRoot extends StatefulWidget {
  const AmadeusRoot({
    super.key,
    required this.viewModel,
    this.localGgufService,
  });

  final AmadeusViewModel viewModel;
  final LlamaGgufService? localGgufService;

  @override
  State<AmadeusRoot> createState() => _AmadeusRootState();
}

class _AmadeusRootState extends State<AmadeusRoot> {
  AppState _state = AppState.intro;

  void _goToCalling() => setState(() => _state = AppState.calling);

  void _onConnected() {
    widget.viewModel.onConnected();
    setState(() => _state = AppState.chat);
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case AppState.intro:
        return IntroScreen(onStart: _goToCalling);
      case AppState.calling:
        return CallingScreen(
          onConnected: _onConnected,
          expression: widget.viewModel.uiState.currentExpression,
        );
      case AppState.chat:
        return ChatScreen(
          viewModel: widget.viewModel,
          onSwitchPersonality: widget.viewModel.setPersonality,
        );
    }
  }
}
