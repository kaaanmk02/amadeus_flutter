import 'package:audioplayers/audioplayers.dart';

/// Ses dosyalarını oynatır / durdurur. `SoundManager.java` karşılığı.
class SoundManager {
  final AudioPlayer _player = AudioPlayer();

  bool _muted = false;

  bool get muted => _muted;

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

  Future<void> loop(String assetPath) async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // yoksay
    }
  }

  Future<void> next() async {
    try {
      // Bir sonraki ses dosyası yüklenebilir.
    } catch (_) {
      // yoksay
    }
  }

  Future<void> stopAllAudio() async {
    try {
      await _player.stop();
    } catch (_) {
      // yoksay
    }
  }

  Future<void> mute() async {
    _muted = !_muted;
  }

  void dispose() => _player.dispose();
}
