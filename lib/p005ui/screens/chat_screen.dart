import 'package:flutter/material.dart';

import '../../data/model/amadeus_ui_state.dart';
import '../../data/model/chat_message.dart';
import '../../data/model/kurisu_expression.dart';
import '../../data/model/personality_type.dart';
import '../../p005ui/viewmodel/amadeus_view_model.dart';
import '../theme/app_theme.dart';
import '../widgets/kurisu_avatar.dart';

/// Sohbet ekranı. `ChatScreen` composable'ı karşılığı.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.viewModel,
    required this.onSwitchPersonality,
  });

  final AmadeusViewModel viewModel;
  final void Function(PersonalityType type) onSwitchPersonality;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.viewModel.uiState;
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              personality: state.currentPersonality,
              divergence: state.divergenceMeter,
              onSwitchPersonality: widget.onSwitchPersonality,
            ),
            Expanded(
              child: state.isChatCollapsed
                  ? _buildCollapsed(state)
                  : _buildMessages(state),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ChatExporterButtons(messages: state.messages),
            ),
            _InputBar(
              controller: _controller,
              isListening: state.isListening,
              onSend: () {
                final text = _controller.text;
                if (text.trim().isEmpty) return;
                _controller.clear();
                widget.viewModel.sendMessage(text, null);
              },
              onMic: widget.viewModel.toggleListening,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsed(AmadeusUiState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KurisuAvatar(expression: state.currentExpression, size: 160),
          const SizedBox(height: 16),
          Text(
            state.isThinking ? 'Düşünüyor...' : 'Hazır',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(AmadeusUiState state) {
    final messages = state.messages;
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length + (state.isThinking ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && state.isThinking) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final message = messages[messages.length - index - 1];
        return _MessageBubble(message: message);
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.personality,
    required this.divergence,
    required this.onSwitchPersonality,
  });

  final PersonalityType personality;
  final String? divergence;
  final void Function(PersonalityType type) onSwitchPersonality;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.bgChat,
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A35))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppTheme.bgDeep,
                isScrollControlled: true,
                builder: (ctx) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SettingsSheet(viewModel: widget.viewModel),
                ),
              );
            },
            icon: const Icon(Icons.settings, color: AppTheme.accentAmber),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KİŞİLİK: ${personality.name.toUpperCase()}',
                  style: const TextStyle(
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.viewModel.customSystemPrompt.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      final controller = TextEditingController(
                        text: widget.viewModel.customSystemPrompt,
                      );
                      final newPrompt = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.bgChat,
                          title: const Text('Özel Sistem Promptu',
                              style: TextStyle(color: AppTheme.textPrimary)),
                          content: TextField(
                            controller: controller,
                            maxLines: 10,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Prompt metni...',
                              hintStyle: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, controller.text),
                              child: const Text('Kaydet'),
                            ),
                          ],
                        ),
                      );
                      if (newPrompt != null && context.mounted) {
                        await widget.viewModel.setCustomSystemPrompt(newPrompt);
                      }
                    },
                    child: const Text('Prompt değiştir',
                        style: TextStyle(color: AppTheme.accentAmber, fontSize: 12)),
                  ),
                if (widget.viewModel.customSystemPrompt.isEmpty)
                  TextButton(
                    onPressed: () async {
                      final controller = TextEditingController();
                      final newPrompt = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.bgChat,
                          title: const Text('Özel Sistem Promptu',
                              style: TextStyle(color: AppTheme.textPrimary)),
                          content: TextField(
                            controller: controller,
                            maxLines: 10,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Prompt metni...',
                              hintStyle: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, controller.text),
                              child: const Text('Kaydet'),
                            ),
                          ],
                        ),
                      );
                      if (newPrompt != null && context.mounted) {
                        await widget.viewModel.setCustomSystemPrompt(newPrompt);
                      }
                    },
                    child: const Text('Prompt ekle',
                        style: TextStyle(color: AppTheme.accentAmber, fontSize: 12)),
                  ),
              ],
            ),
          ),
          if (divergence != null)
            Text(
              'DIVERGENCE: $divergence',
              style: const TextStyle(
                color: AppTheme.accentAmber,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.accentGreen : AppTheme.bgChat,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? AppTheme.bgDeep : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isListening,
    required this.onSend,
    required this.onMic,
  });

  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onSend;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppTheme.bgChat,
        border: Border(top: BorderSide(color: Color(0xFF2A2A35))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMic,
            icon: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening ? AppTheme.accentRed : AppTheme.accentGreen,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Bir şey söyle...',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send, color: AppTheme.accentGreen),
          ),
        ],
      ),
    );
  }
}
