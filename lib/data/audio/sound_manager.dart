import 'package:audioplayers/audioplayers.dart';

/// Ses dosyalarını oynatır / durdurur. `SoundManager.java` karşılığı.
class SoundManager {
  final AudioPlayer _player = AudioPlayer();

  /// `SoundManager.playSound(file, loop)` karşılığı.
  Future<void> play(String assetPath, {bool loop = false}) async {
    try {
      await _player.setReleaseMode(
          loop ? ReleaseMode.loop : ReleaseMode.stop);
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Ses çalınamadığında sohbeti bozma.
    }
  }

  Future<void> stopAllAudio() async {
    try {
      await _player.stop();
    } catch (_) {
      // yoksay
    }
  }

  void dispose() => _player.dispose();
}
