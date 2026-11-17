# Amadeus — Steins;Gate 0 temalı yapay zekâ sohbet uygulaması (Flutter)

Amadeus, decompile edilmiş Android APK'sının Java kaynağından Flutter/Dart'e
çevrilerek yeniden yazılmış bir asistan uygulamasıdır. Karakter, Steins;Gate
dünyasındaki Makise Kurisu'nun "Amadeus" adlı dijital hâline dayanır:
sohbet, kişilik profilleri, ifade animasyonu ve Japonca seslendirme.

- Depo: `kaaanmk02/amadeus_flutter` (public)
- Flutter: 3.47.9 (stable) · Dart: 3.13.7
- Hedef platform: Android (APK)

---

## Özellikler

- Modele bağımsız karakter sözleşmesi; 7 kişilik stili ve yoğunluk ayarı.
- Yapılandırılmış duygu çıktısı (emotion/intensity) ve avatar ifade animasyonu.
- Çevrim içi OpenAI uyumlu uç nokta, yerel GGUF model (llama_flutter_android)
  ve hibrit yedekleme akışı.
- TTS: çevrim içi Fish Audio + çevrim dışı Android TTS; otomatik sağlayıcı seçimi.
- STT: Android konuşma tanıma (yalnızca nihai metin gönderilir).
- Kalıcı hafıza kayıtları ve oturum arşivi (oturum özetleme, anahtar kelime arama).
- Kamera/galeri görsel girişi (çevrim içi görsel destekli model gerekir).
- Uygulama içi bildirimler; oturumların şifreli saklanması.

## Dosya yapısı

```
lib/
  main.dart                     # Giriş noktası (AmadeusRoot + ViewModel injection)
  core/                         # app_config, app_state, exceptions, amadeus_assets
  domain/                       # personality_manager (kişilik sözleşmeleri)
  data/
    model/                      # chat, duygu, kişilik, hafıza modelleri
    repository/                 # AmadeusRepository (oturum + ayar erişimi)
    ai/                         # local_llm_manager, llama_gguf_service
    network/                    # llm_api (SSE akışı)
    audio/                      # speech_manager, sound_manager, fish_audio_tts
    storage/                    # settings, memory, session, chat_exporter
    notification/               # NotificationManager (iç bildirimler)
  p005ui/
    screens/                    # intro, calling, chat, memory_log, settings_sheet
    widgets/                    # kurisu_avatar, personality_animator, exporter
    theme/                      # AppTheme
    viewmodel/                  # AmadeusViewModel (ChangeNotifier)
assets/
  expressions/                  # 174 karakter PNG'si + transition_fade_scale.json
  voices/oneshot/               # CRS_EN/IT/JP sesleri + uzatılmış MP3
android/app/                    # build.gradle, AndroidManifest, MainActivity.kt
.github/workflows/build-apk.yml # Release APK CI
```

## Varlıklar ve lisanslar

- `assets/expressions/` PNG'leri orijinal proje çıkışlıdır; kredi bildirimi
  `assets/expressions/CREDITS.txt` içindedir. Bu bildirim silinmemeli ve karakter
  görselleri ayrı olarak dağıtılmalıdır.
- `assets/voices/oneshot/` sesleri Amadeus ses arşivinden alınmıştır.
- Opsiyonel (indirilmedi): Kenney CC0 UI ses paketleri
  (Interface Sounds / UI Audio / Digital Audio, https://kenney.nl) — gelecekte
  `assets/sounds/` için aday. Hiçbir telifli anime sesi veya dışarıdan karakter
  görseli eklenmemiştir.

## Kurulum ve geliştirme

```bash
cd amadeus_flutter
flutter pub get
flutter analyze          # hedef: 0 error
```

Yerel APK üretimi (not: Gradle 9.3.1, Java 27 ile çalışmaz; Java 17 kullanılmalı):

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH
export ANDROID_HOME=$HOME/Android/Sdk
flutter build apk --release
# çıktı: android/app/build/outputs/flutter-apk/app-release.apk
```

Not: Bu proje Flutter 3.47'de APK'yı `android/app/build/outputs/flutter-apk/`
altına koyar; `flutter build apk` çıktı yolunu bulamadığı için uyarı verebilir.
Doğrudan derlemek için:

```bash
cd android && ./gradlew :app:assembleRelease
```

## APK üretimi (GitHub Actions)

Her `main`/`master` push'u veya elle tetikleme `.github/workflows/build-apk.yml`
ile imzalı release APK üretir ve `amadeus-apk` adıyla artifact yükler.

Gerekli depo secret'ları (Settings → Secrets and variables → Actions):

| Secret | İçerik |
|---|---|
| `KEYSTORE_BASE64` | `android/app/release.keystore` dosyasının base64 hali |
| `STORE_PASS` | Keystore şifresi |
| `KEY_PASS` | Anahtar (alias `amadeus`) şifresi |

Keystore depoya konmaz (public depo). Yerelde `android/app/release.keystore`
bulunur; build.gradle `file("release.keystore")` yolunu kullanır.

## Bilinen eksikler / yol haritası

- Rust motoru: UI'da `RUST (BETA)` seçeneği var, ancak native kütüphane/FFI
  köprüsü yok; seçilince kullanıcıya eksik bildirilir.
- Gerçek çevrim dışı STT (Whisper) entegre edilmedi; Android sistem tanıma
  servisi kullanılıyor.
- Ekran yakalama, takvim bağlantısı, otonom arka plan ajanı yok.
- Kamera/galeri görseli alınır ama görsel anlama çevrim içi bir model ister.
- Yerel GGUF model cihazda ölçülenmedi; ilk çalıştırmada ~1,9 GB model indirilir.
- Görsel ifade seçimi anahtar kelime tabanlı basit bir sınıflandırıcıdır; gerçek
  duygu analizi değildir.

## Sürüm geçmişi (özet)

- v1.3–v1.6: PNG ifade entegrasyonu, şifreli depolama, oturum özetleme/arşiv,
  TTS sıralama, GGUF indirme düzeni, `RUST (BETA)` seçeneği.
- Core v2 / 2.0.0: kişilik sözleşmesi, oturum rotasyonu, görsel giriş, testler.
- Bu sürüm: CI (GitHub Actions), pubspec/gradle tam kurulum, manifest izinleri
  ve giriş noktası düzeltmeleri.

## Güvenlik notları

- API anahtarları FlutterSecureStorage / Android Keystore alanında tutulur;
  sabit anahtar gömülü değildir.
- Hafıza kayıtları güvenli depoda saklanır; eski düz JSON ilk açılışta taşınır.
- Görseller kalıcı sohbet geçmişine base64 olarak yazılmaz.
- Keystore ve `android/local.properties` depoya girmez (`.gitignore`).
