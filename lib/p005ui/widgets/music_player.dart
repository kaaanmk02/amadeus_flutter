/// KURISU MÜZİĞİ - Müzik çalıştırıcı widget'ı
///
/// Telefon: Kurisu'nin altında oynatıcı, şarkı seçimi, bildirim okuma
/// PC: Solda Kurisu, sağda yazı/sohbet, müzik çalyısının arada olması
///
/// Kullanım:
///   KurisuMusicPlayer(
///     songs: songList,
///     isPlaying: isPlaying,
///     currentIndex: currentIndex,
///     volume: 0.8,
///     onPlay: () => _play(),
///     onStop: () => null,
///     onNext: () => _next(),
///     onPrev: () => _prev(),
///   )

library;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import 'kurisu_avatar.dart';

class KurisuMusicPlayer extends StatefulWidget {
  final List<Map<String, dynamic>> songs;
  final bool isPlaying;
  final int currentIndex;
  final double volume;
  final bool isMobile; // Telefon mı, PC mi
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final ValueChanged<int> onSongChanged;

  const KurisuMusicPlayer({
    super.key,
    required this.songs,
    required this.isPlaying,
    required this.currentIndex,
    required this.volume,
    required this.isMobile,
    required this.onPlay,
    required this.onStop,
    required this.onNext,
    required this.onPrev,
    required this.onSongChanged,
  });

  @override
  State<KurisuMusicPlayer> createState() => _KurisuMusicPlayerState();
}

class _KurisuMusicPlayerState extends State<KurisuMusicPlayer> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(widget.volume * 100);
    // Başlangıçta ilk şarkıyı oynat
    if (widget.songs.isNotEmpty && widget.currentIndex >= 0) {
      _loadSong(widget.currentIndex);
    }
  }

  @override
  void didUpdateWidget(KurisuMusicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _loadSong(widget.currentIndex);
      } else {
        _audioPlayer.stop();
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _loadSong(int index) {
    if (index < 0 || index >= widget.songs.length) return;
    final song = widget.songs[index];
    _audioPlayer.stop();
    // AssetSource: Flutter assets paketi içindeki dosyaları çalıştırır.
    // DeviceFileSource: dosya sistemi yolu; AssetSource: pkg içi kaynak.
    if (song['path'] != null) {
      _audioPlayer.play(AssetSource(song['path']));
    } else if (song['url'] != null) {
      _audioPlayer.play(UrlSource(song['url']));
    }
  }

  void _playPause() {
    if (widget.isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
    widget.onPlay();
  }

  void _prev() {
    final prevIndex = (widget.currentIndex - 1) % widget.songs.length;
    widget.onSongChanged(prevIndex);
    widget.onPlay();
  }

  void _next() {
    final nextIndex = (widget.currentIndex + 1) % widget.songs.length;
    widget.onSongChanged(nextIndex);
    widget.onPlay();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.music_note, color: AppTheme.accentRed),
                const SizedBox(width: 8),
                Text(
                  widget.songs.isNotEmpty
                      ? (widget.songs[widget.currentIndex]['title'] ?? 'Bilinmeyen')
                      : 'Hiç şarkı yok',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                if (widget.isMobile)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Bildirim Okundu',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.accentRed,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),

          // Oyuncak (telefon: Kurisu'nin altında, PC: solda)
          Row(
            children: [
              // Kurisu
              SizedBox(
                width: widget.isMobile ? 60 : 80,
                height: widget.isMobile ? 60 : 80,
                child: KurisuAvatar(
                  size: widget.isMobile ? 60 : 80,
                  isSpeaking: false,
                  isThinking: false,
                ),
              ),
              const SizedBox(width: 12),
              // Ölçekli kontroller
              Expanded(
                child: widget.isMobile
                    ? _buildMobileControls()
                    : _buildPCControls(),
              ),
            ],
          ),

          // Şarkı widget'ı
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.queue_music, color: AppTheme.accentRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.songs.isNotEmpty
                        ? (widget.songs[widget.currentIndex]['title'] ?? 'Bilinmeyen')
                        : 'Şarkı seçin',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (widget.songs.length > 1)
                  InkWell(
                    onTap: widget.songs.length > 1 ? _showPlaylist : null,
                    child: const Icon(Icons.arrow_drop_down, size: 18),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: widget.songs.length > 1 ? _prev : null,
            ),
            IconButton(
              icon: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 32,
              ),
              onPressed: _playPause,
              iconSize: 32,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: widget.songs.length > 1 ? _next : null,
            ),
          ],
        ),
        if (widget.songs.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.repeat, size: 16),
                onPressed: null,
              ),
              IconButton(
                icon: const Icon(Icons.shuffle, size: 16),
                onPressed: null,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPCControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: widget.songs.length > 1 ? _prev : null,
              iconSize: 20,
            ),
            IconButton(
              icon: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 32,
              ),
              onPressed: _playPause,
              iconSize: 32,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: widget.songs.length > 1 ? _next : null,
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  void _showPlaylist() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PlaylistSheet(songs: widget.songs, currentIndex: widget.currentIndex, onSelect: widget.onSongChanged),
    );
  }
}

/// Şarkı listeden seçim yapmak için modalan tamamlanması
class _PlaylistSheet extends StatelessWidget {
  final List<Map<String, dynamic>> songs;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _PlaylistSheet({required this.songs, required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${songs.length} Şarkı',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final isPlaying = index == currentIndex;
                return ListTile(
                  leading: isPlaying
                      ? const CircleAvatar(backgroundColor: AppTheme.accentRed, child: Icon(Icons.play_arrow, color: Colors.white, size: 20))
                      : const CircleAvatar(backgroundColor: AppTheme.accentRed, child: Icon(Icons.track_changes, color: Colors.white, size: 16)),
                  title: Text(songs[index]['title'] ?? 'Bilinmeyen'),
                  subtitle: Text(songs[index]['artist'] ?? ''),
                  trailing: isPlaying ? const SizedBox.shrink() : const Icon(Icons.chevron_right),
                  onTap: () {
                    onSelect(index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Tekrar başlat
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Tekrar'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
