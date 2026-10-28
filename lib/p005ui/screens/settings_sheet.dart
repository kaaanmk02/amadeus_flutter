import 'package:flutter/material.dart';

import '../../data/model/personality_type.dart';
import '../../data/ai/llama_gguf_service.dart';
import '../theme/app_theme.dart';
import '../viewmodel/amadeus_view_model.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({required this.viewModel, super.key});

  final AmadeusViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.bgDeep : const Color(0xFFF3F3F3);
    final text = isDark ? AppTheme.textPrimary : const Color(0xFF111111);
    final hint = isDark ? AppTheme.textSecondary : const Color(0xFF666666);
    final card = isDark ? AppTheme.bgChat : const Color(0xFFE6E6E6);

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: hint, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 12),
          _SectionTitle('Model Ayarları', text),
          const SizedBox(height: 8),
          _Field(
            label: 'API Adresi',
            value: viewModel.apiUrl,
            hint: 'http://localhost:11434',
            card: card,
            text: text,
            hintC: hint,
            onSave: (v) => viewModel.setApiUrl(v),
          ),
          const SizedBox(height: 8),
          _Field(
            label: 'Model',
            value: viewModel.modelName,
            hint: 'llama3',
            card: card,
            text: text,
            hintC: hint,
            onSave: (v) => viewModel.setModelName(v),
          ),
          const SizedBox(height: 8),
          _Field(
            label: 'API Anahtarı',
            value: viewModel.apiKey,
            hint: '[REDACTED]',
            isPassword: true,
            card: card,
            text: text,
            hintC: hint,
            onSave: (v) => viewModel.setApiKey(v),
          ),
          const SizedBox(height: 12),
          _SectionTitle('Kişilik', text),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: PersonalityType.values
                  .map((t) => _ChoiceChip(
                        label: t.name.toUpperCase(),
                        selected: viewModel.currentPersonality == t,
                        card: card,
                        selectedBg: AppTheme.accentGreen,
                        text: text,
                        onTap: () => viewModel.setPersonality(t),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SectionTitle('Bağlam Penceresi', text),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('Son ${viewModel.contextWindow} mesaj', style: TextStyle(color: text)),
              ),
              IconButton(
                onPressed: () => viewModel.setContextWindow((viewModel.contextWindow - 2).clamp(2, 50)),
                icon: const Icon(Icons.remove_circle_outline, color: AppTheme.accentGreen),
              ),
              Text('${viewModel.contextWindow}', style: TextStyle(color: text)),
              IconButton(
                onPressed: () => viewModel.setContextWindow((viewModel.contextWindow + 2).clamp(2, 50)),
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionTitle('TTS Ses Sağlayıcı', text),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['online', 'offline']
                  .map((provider) => _ChoiceChip(
                        label: provider.toUpperCase(),
                        selected: viewModel.ttsProvider == provider,
                        card: card,
                        selectedBg: AppTheme.accentGreen,
                        text: text,
                        onTap: () => viewModel.setTtsProvider(provider),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('Otomatik ses üretme', style: TextStyle(color: text)),
              ),
              Switch(
                value: viewModel.autoSpeak,
                onChanged: (v) => viewModel.setAutoSpeak(v),
                activeColor: AppTheme.accentGreen,
              ),
            ],
          ),
  const SizedBox(height: 12),
  _SectionTitle('Yerel Model (GGUF)', text),
  const SizedBox(height: 8),
  Row(
    children: [
      Expanded(
        child: Text(
          'Model: ${viewModel.localModelName}',
          style: TextStyle(color: text),
        ),
      ),
      TextButton(
        onPressed: () async {
          final service = LlamaGgufService.instance;
          final downloaded = await service.downloadModel();
          if (downloaded) {
            final path = await service.localModelPath();
            await viewModel.setLocalModelPath(path);
          }
        },
        child: const Text('İndir', style: TextStyle(color: AppTheme.accentGreen)),
      ),
      TextButton(
        onPressed: () async {
          final service = LlamaGgufService.instance;
          final loaded = await service.loadModel();
          if (loaded) {
            await viewModel.setLocalModelPath(await service.localModelPath());
          }
        },
        child: const Text('Yükle', style: TextStyle(color: AppTheme.accentGreen)),
      ),
    ],
  ),
  const SizedBox(height: 12),
  _SectionTitle('Sistem Promptu (Özel)', text),
          const SizedBox(height: 8),
          _MultilineField(
            value: viewModel.customSystemPrompt,
            card: card,
            text: text,
            hintC: hint,
            onSave: (v) => viewModel.setCustomSystemPrompt(v),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.color);
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: TextStyle(
              color: AppTheme.accentAmber,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            )),
      );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.hint,
    required this.card,
    required this.text,
    required this.hintC,
    required this.onSave, this.isPassword = false,
  });
  final String label;
  final String value;
  final String hint;
  final bool isPassword;
  final Color card;
  final Color text;
  final Color hintC;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value.isEmpty ? hint : value);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: ctrl,
              obscureText: isPassword,
              style: TextStyle(color: text),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: hintC),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        TextButton(onPressed: () => onSave(ctrl.text), child: const Text('Kaydet', style: TextStyle(color: AppTheme.accentGreen))),
      ],
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.value,
    required this.card,
    required this.text,
    required this.hintC,
    required this.onSave,
  });
  final String value;
  final Color card;
  final Color text;
  final Color hintC;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: ctrl,
              maxLines: 6,
              style: TextStyle(color: text),
              decoration: InputDecoration(
                hintText: 'Özel prompt...',
                hintStyle: TextStyle(color: hintC),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextButton(onPressed: () => onSave(ctrl.text), child: const Text('Kaydet', style: TextStyle(color: AppTheme.accentGreen))),
        )
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.card,
    required this.selectedBg,
    required this.text,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color card;
  final Color selectedBg;
  final Color text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: selected ? selectedBg : card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? selectedBg : const Color(0xFF2A2A35)),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? AppTheme.bgDeep : text,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}
