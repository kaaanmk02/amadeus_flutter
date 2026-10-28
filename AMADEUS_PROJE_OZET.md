# AMADEUS Flutter Proje Özeti
## Genel Bakış
Amadeus APK decompile edilmiş Java kaynağından Flutter/Dart projesine satır satır eşleşme ile çevrildi. APK derlemesi yapılmadı; kullanıcı kendi PC'sinde Flutter ile derleyecektir.

## Kaynaklar
- Decompiled Java: `/root/.hermes/cache/scratch/amadeus/clean/` (jadx ile 10.459 dosya)
- Çıkarılan sistem promptu: `/root/.hermes/cache/scratch/prompt.txt`
- Flutter proje: `/root/amadeus_flutter/`

## Oluşturulan Dosyalar (lib/ 25 Dart dosyası)
### Core
- `lib/core/app_config.dart` — API endpoint, model ayarları, uygulama sabitleri
- `lib/core/app_state.dart` — Ekran durum makinesi (intro/calling/chat)
- `lib/core/exceptions.dart` — API hata sınıfları

### Domain
- `lib/domain/personality_manager.dart` — `PersonalityManager.java` karşılığı, sistem promptu embed, kişilik yönetimi

### Data Model
- `lib/data/model/amadeus_ui_state.dart` — UI state + copyWith
- `lib/data/model/chat_message.dart` — Chat mesaj modeli
- `lib/data/model/kurisu_expression.dart` — Kurisu ifade enums
- `lib/data/model/memory_data.dart` — Hafıza verisi modeli
- `lib/data/model/mood_state.dart` — Ruh hali enum
- `lib/data/model/personality_state.dart` — Kişilik durumu + copyWith
- `lib/data/model/personality_type.dart` — Kişilik tipleri enum

### Data Repository
- `lib/data/repository/amadeus_repository.dart` — Repository arayüzü

### Data AI
- `lib/data/ai/local_llm_manager.dart` — LocalLLM yönetimi

### Data Network
- `lib/data/network/llm_api.dart` — HTTP LLM arama

### Data Audio
- `lib/data/audio/sound_manager.dart` — Ses efektleri
- `lib/data/audio/speech_manager.dart` — Konuşma sentezi

### Data Storage
- `lib/data/storage/settings_manager.dart` — API key [REDACTED], preferences
- `lib/data/storage/memory_manager.dart` — Hafıza yönetimi

### UI
- `lib/p005ui/screens/intro_screen.dart` — Giriş ekranı
- `lib/p005ui/screens/calling_screen.dart` — Arama ekranı
- `lib/p005ui/screens/chat_screen.dart` — Sohbet ekranı
- `lib/p005ui/widgets/kurisu_avatar.dart` — Kurisu avatar widget
- `lib/p005ui/theme/app_theme.dart` — Tema / dark/light
- `lib/p005ui/viewmodel/amadeus_view_model.dart` — Ana ViewModel (sendMessage, onConnected, sendMessageDirectly, copyWith hizalaması)

### Entry Point
- `lib/main.dart` — Başlangıç, MaterialApp, ViewModel injection

## Platform Dosyaları
- `android/` klasörü oluşturuldu:
  - `android/build.gradle`
  - `android/settings.gradle`
  - `android/gradle.properties`
  - `android/gradle/wrapper/gradle-wrapper.properties`
  - `android/app/build.gradle` (signingConfigs.release, minifyEnabled false)
  - `android/app/src/main/AndroidManifest.xml` (INTERNET, RECORD_AUDIO)
  - `android/app/src/main/java/com/example/amadeus/MainActivity.java`
  - `android/app/src/main/res/values/styles.xml`
- `pubspec.yaml` güncellendi (assets/models/ eklendi)

## Doğrulananlar
- Tüm 25 Dart dosyası decompiled Java karşılıklarıyla mevcut
- `settings_manager.dart` içinde `getApiKey()` varsayılan değeri `'[REDACTED]'`
- ViewModel method imzaları Java ile eşleşiyor
- Sistem promptu decode edilip `prompt.txt`'ye kaydedildi

## Kullanıcıya Dikkat
- Keystore yolu `android/app/build.gradle` içinde göreceli: `../../amadeus.jks` — kendi keystore yolunuza göre düzeltin.
- Derleme sırasında gradle wrapper indirilecektir; internet bağlantısı gereklidir.
- `flutter run` / `flutter build apk` kendi PC'nizde çalıştırın.
