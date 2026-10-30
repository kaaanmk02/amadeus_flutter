import 'package:flutter/material.dart';
import '../../viewmodel/amadeus_view_model.dart';

class MusicGenreSelector extends StatelessWidget {
  const MusicGenreSelector({required this.viewModel, super.key});
  final AmadeusViewModel viewModel;

  static const genres = <String>['', 'amadeus_ost', 'metal', 'classical', 'jazz', 'electronic', 'ambient'];

  static const amadeusOstTracks = <String>[
    'Another Heaven Short Ver.',
    'Assailant',
    'Believe me',
    'Chaos mind',
    'Crossroads',
    'Cycle',
    'Explanation',
    'Fake Verthandi',
    'GATE OF STEINER -Main theme-',
    'GATE OF STEINER -Piano-',
    'Hack -alpha vision-',
    'Hack -beta vision-',
    'Hack -short vision-',
    'Human community',
    'Laboratory',
    'Network battle',
    'Noisy times',
    'OPERATION SKULD',
    'Quiet air',
    'Ringing -Beginning of fight-',
    'Ringing -Easygoingness-',
    'Ringing -GATE OF STEINER-',
    'Ringing -Over the sky-',
    'Ringing -Precaution-',
    'Ringing -Reunion-',
    'Ringing -Village-',
    'SERN',
    'Select of sorrow',
    'Self affirmation',
    'Solitude',
    'Suspicious eyes',
    'The Limit',
    'Urd',
    'Walking on sleeping',
    'Yanagibayashi',
    'hesitative consideration',
    'prologue',
    'スカイクラッドの観測者 Short Ver.',
    'マスカレード ～ノア第三章列王新世紀編より～ Short Ver.',
    '運命のファルファッラ Short Ver.',
  ];

  @override
  Widget build(BuildContext context) {
    final current = viewModel.musicGenre;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Arka plan müziği', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: genres
              .map((g) => ChoiceChip(
                    label: Text(g.isEmpty ? 'Yok' : g == 'amadeus_ost' ? 'AMADEUS OST' : g.toUpperCase()),
                    selected: current == g,
                    onSelected: (_) async {
                      await viewModel.setMusicGenre(g);
                      await viewModel.playMusicForGenre(g);
                    },
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        if (current == 'amadeus_ost') ...[
          Text('Şarkı seç:', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: amadeusOstTracks
                .map((t) => ActionChip(
                      label: Text(t),
                      onPressed: () => viewModel.playAmadeusTrack(t),
                    ))
                .toList(),
          ),
        ] else if (current.isNotEmpty)
          Text(
            current == 'metal'
                ? 'Metal → avatar daha enerjik/kızgın.'
                : current == 'classical'
                    ? 'Klasik → avatar daha bilimsel/ciddi.'
                    : '$current → duygu katmanı etkilenir.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          const Text('Müzik modülasyonu kapalı.'),
      ],
    );
  }
}
