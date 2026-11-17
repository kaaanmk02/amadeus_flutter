import re

with open('lib/data/audio/speech_manager.dart', 'r') as f:
    content = f.read()

# Add missing imports after dart:io
content = content.replace(
    "import 'dart:io';",
    "import 'dart:io';\nimport 'package:flutter_tts/flutter_tts.dart';\nimport 'package:audioplayers/audioplayers.dart';\nimport 'package:connectivity_plus/connectivity_plus.dart';"
)

# Fix SpeechListenOptions to use listenOptions named parameter
old_listen = """    _stt.listen(
      onResult: (result) {
        // Ignore interim hypotheses: only a final recognition becomes a chat message.
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          onResult(result.recognizedWords.trim());
        }
      },
      SpeechListenOptions(
        localeId: 'tr_TR',
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 3),
      ),
    );"""

new_listen = """    _stt.listen(
      onResult: (result) {
        // Ignore interim hypotheses: only a final recognition becomes a chat message.
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          onResult(result.recognizedWords.trim());
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'tr_TR',
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 3),
      ),
    );"""

content = content.replace(old_listen, new_listen)

with open('lib/data/audio/speech_manager.dart', 'w') as f:
    f.write(content)
print('speech_manager.dart fixed')
