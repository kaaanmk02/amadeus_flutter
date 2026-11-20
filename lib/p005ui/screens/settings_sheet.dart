import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 4),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 1.2),
      ),
    );
  }
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({required this.viewModel, super.key});
  final dynamic viewModel;

  static Future<void> show(BuildContext context, {dynamic viewModel}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgDeep,
      isScrollControlled: true,
      builder: (_) => SettingsSheet(viewModel: viewModel),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  String _language = 'Turkish';
  String _theme = 'Dark';
  String _ttsProvider = 'online';
  String _aiEngine = 'online';
  bool _autoSpeak = true;
  bool _useApiProxy = false;
  String _apiKey = '';
  String _modelName = '';
  String _apiUrl = '';
  double _intensity = 0.7;
  String _personality = 'tsundere';
  String? _localModelPath;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  void _loadValues() {
    final vm = widget.viewModel;
    if (vm != null) {
      final s = vm.repository.settings;
      _language = _languageFrom(s.getLanguage() ?? 'Turkish');
      _theme = _themeFrom(s.getThemeMode() ?? 'Dark');
      _ttsProvider = s.getTtsProvider() ?? 'online';
      _aiEngine = s.getAiEngine() ?? 'online';
      _autoSpeak = s.getAutoSpeak() ?? true;
      _useApiProxy = s.getUseApiProxy() ?? false;
      _apiKey = s.getApiKey() ?? '';
      _modelName = s.getModelName() ?? '';
      _apiUrl = s.getApiUrl() ?? '';
      _intensity = s.getIntensity() ?? 0.7;
      _personality = s.getPersonality() ?? 'tsundere';
      _localModelPath = s.getLocalModelPath();
    }
  }

  String _languageFrom(String name) =>
      name.toLowerCase().contains('ing') ? 'English' : 'Turkish';

  String _themeFrom(String mode) {
    if (mode.toLowerCase().contains('dark')) return 'Dark';
    if (mode.toLowerCase().contains('light')) return 'Light';
    return 'Dark';
  }

  Future<void> _save() async {
    final vm = widget.viewModel;
    if (vm != null) {
      await vm.setLanguage(_language == 'Turkish' ? 'tr' : 'en');
      await vm.setThemeMode(_theme == 'Dark' ? 'dark' : _theme == 'Light' ? 'light' : 'dark');
      await vm.setTtsProvider(_ttsProvider);
      await vm.setAiEngine(_aiEngine);
      await vm.setAutoSpeak(_autoSpeak);
      await vm.setUseApiProxy(_useApiProxy);
      await vm.setApiKey(_apiKey);
      await vm.setModelName(_modelName);
      await vm.setApiUrl(_apiUrl);
      await vm.setIntensity(_intensity);
      await vm.setPersonality(_personality);
      if (_localModelPath != null && _localModelPath!.isNotEmpty) {
        await vm.setLocalModelPath(_localModelPath);
      } else {
        await vm.setLocalModelPath(null);
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ayarlar kaydedildi.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  Widget _buildField(String label, String value, {VoidCallback? onTap, Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            if (trailing != null) trailing
            else if (onTap != null) const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary)
            else const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgDeep,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SectionTitle(title: 'Settings'),
          _buildField('Language', _language, onTap: () => {setState(() => _language = _language == 'Turkish' ? 'English' : 'Turkish')}),
          _buildField('Theme', _theme, onTap: () => {setState(() {
            _theme = _theme == 'Dark' ? 'Light' : _theme == 'Light' ? 'System' : 'Dark';
          })}),
          _buildField('Intensity', '${(_intensity * 100).round()}%', onTap: () => {setState(() => _intensity = (_intensity + 0.1).clamp(0.0, 1.0))}),
          _buildField('Personality', _personality, onTap: () => {setState(() => _personality = _personality == 'tsundere' ? 'yandere' : _personality == 'yandere' ? 'kuudere' : _personality == 'kuudere' ? 'dandere' : 'tsundere')}),
          _buildField('AI Engine', _aiEngine, onTap: () => {setState(() => _aiEngine = _aiEngine == 'online' ? 'local_gguf' : 'online')}),
          _buildField('Auto-Speak', _autoSpeak ? 'On' : 'Off', onTap: () => {setState(() => _autoSpeak = !_autoSpeak)}),
          _buildField('API Proxy', _useApiProxy ? 'On' : 'Off', onTap: () => {setState(() => _useApiProxy = !_useApiProxy)}),
          _buildField('API URL', _apiUrl, onTap: () => {}),
          _buildField('Model', _modelName, onTap: () => {}),
          _buildField('API Key', _apiKey.isNotEmpty ? '${_apiKey.substring(0, _apiKey.length > 8 ? 8 : _apiKey.length)}**...' : '—', onTap: () => {}),
          _buildField('Local Model', _localModelPath ?? 'Not selected', onTap: () => {}),
          const _SectionTitle(title: 'Speech'),
          _buildField('TTS Provider', _ttsProvider, onTap: () => {setState(() => _ttsProvider = _ttsProvider == 'online' ? 'offline' : 'online')}),
          const _SectionTitle(title: 'Account'),
          _buildField('Name', 'Guest', onTap: () => {}),
          _buildField('Email', 'guest@example.com', onTap: () => {}),
          const _SectionTitle(title: 'Danger'),
          _buildField('Reset', 'None', onTap: () => {}),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('KAYDET'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}
