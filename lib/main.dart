import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_config.dart';
import 'core/app_state.dart';
import 'data/ai/local_llm_manager.dart';
import 'data/ai/llama_gguf_service.dart';
import 'data/audio/sound_manager.dart';
import 'data/audio/speech_manager.dart';
import 'data/model/kurisu_expression.dart';
import 'data/model/personality_type.dart';
import 'data/network/llm_api.dart';
import 'data/notification/notification_manager.dart';
import 'data/repository/amadeus_repository.dart';
import 'data/storage/memory_manager.dart';
import 'data/storage/settings_manager.dart';
import 'domain/personality_manager.dart';
import 'p005ui/screens/calling_screen.dart';
import 'p005ui/screens/chat_screen.dart';
import 'p005ui/screens/intro_screen.dart';
import 'p005ui/theme/app_theme.dart';
import 'p005ui/viewmodel/amadeus_view_model.dart';

/// AMADEUS — Kurisu Makise dijital hafızası.
/// Kaynak: `com.example.amadeus` APK'ı (jadx ile kurtarıldı).
/// Derleme: `flutter build apk --release` (PC'de).
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AmadeusApp());
}

class AmadeusApp extends StatelessWidget {
  const AmadeusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AmadeusRoot(),
    );
  }
}

/// `AppState` durum makinesi + ViewModel yaşam döngüsü.
class AmadeusRoot extends StatefulWidget {
  const AmadeusRoot({super.key});

  @override
  State<AmadeusRoot> createState() => _AmadeusRootState();
}

class _AmadeusRootState extends State<AmadeusRoot> {
  AppState _state = AppState.intro;

  late final SoundManager _soundManager;
  late final SpeechManager _speechManager;
  late final LocalLlmManager _localLlmManager;
  late final LlamaGgufService _localGgufService;

  AmadeusViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _soundManager = SoundManager();
    _speechManager = SpeechManager();
    _localLlmManager = LocalLlmManager();
    _bootstrap();
  }

  /// Ayarlar + hafıza main thread'i bloklamadan asenkron yüklenir.
  Future<void> _bootstrap() async {
    final settings = await SettingsManager.load();
    final memoryManager = await MemoryManager.load();

    final viewModel = AmadeusViewModel(
      repository: AmadeusRepository(
        api: LlmApi(settings: settings),
        settings: settings,
        personalityManager: const PersonalityManager(),
        memoryManager: memoryManager,
      ),
      soundManager: _soundManager,
      speechManager: _speechManager,
      localLlmManager: _localLlmManager,
      onSpeak: _speechManager.speak,
      onExpressionChanged: (_) {},
    );

    if (!mounted) {
      viewModel.dispose();
      return;
    }
    setState(() => _viewModel = viewModel);
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    _viewModel?.dispose();
    _soundManager.dispose();
    _speechManager.dispose();
    super.dispose();
  }

  void _onStart() {
    setState(() => _state = AppState.calling);
  }

  void _onConnected() {
    setState(() => _state = AppState.chat);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    switch (_state) {
      case AppState.intro:
        return IntroScreen(onStart: _onStart);
      case AppState.calling:
        return CallingScreen(
          onConnected: _onConnected,
          expression: viewModel?.uiState.currentExpression ?? KurisuExpression.normal,
        );
      case AppState.chat:
        if (viewModel == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0F),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ChatScreen(
          viewModel: viewModel,
          onSwitchPersonality: viewModel.setPersonality,
        );
    }
  }
}
