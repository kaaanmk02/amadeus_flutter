# Amadeus Flutter Project - Asset & Feature Expansion Summary

## External Assets Added

### Expression PNGs (174 files)
Source: `/sdcard/Download/PC _ Computer - Steins;Gate 0 - Characters - Makise Kurisu (Amadeus).zip`
Destination: `/root/amadeus_flutter/assets/expressions/`
- `CRS_JLD_*.png` (72 images - dialogue expressions)
- `CRS_JLE_*.png` (72 images - alternative expressions)
- Others: various Amadeus UI states

### Voice Assets (4 files)
Source: `https://github.com/FrancescoCaracciolo/Amadeus.git`
Destination: `/root/amadeus_flutter/assets/voices/oneshot/`
- `CRS_EN.wav` (English voice)
- `CRS_IT.wav` (Italian voice)
- `CRS_JP.wav` (Japanese voice)
- `CRS_IT_LONG.mp3` (Extended Italian audio)

### Animation Asset (1 file)
- `transition_fade_scale.json` - Generic fade/scale Lottie animation for expression transitions

## Code Changes

### New Files
- `lib/data/model/kurisu_expression_asset.dart` - Maps expressions to PNG paths
- `lib/data/model/personality_animation.dart` - Animation model (scale/rotation/offset)
- `lib/data/storage/chat_exporter.dart` - Export chat to TXT/JSON
- `lib/p005ui/widgets/personality_animator.dart` - Animated expression widget

### Modified Files
- `pubspec.yaml` - Added `assets/expressions/` and `assets/voices/oneshot/`
- `lib/core/amadeus_assets.dart` - Asset path constants
- `lib/data/audio/speech_manager.dart` - Connectivity-based online/offline fallback
- `lib/data/tts/fish_audio_tts.dart` - Moved online check into synthesize()

## Pending (Placeholder Implementations)
- `SecureMemoryManager` - Requires crypto package for real encryption
- `ChatExporter` - Requires permission_handler for Android storage
- `PersonalityAnimator` - Needs integration into chat UI

## Next Steps
1. Wire `PersonalityAnimator` into chat message bubbles
2. Add export buttons to chat screen
3. Test APK build with assets included

---
Generated: 2026-10-27
Project: /root/amadeus_flutter
