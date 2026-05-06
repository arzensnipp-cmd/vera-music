# Vera Music 🎵

Vera Music Beta - YouTube tabanlı müzik indirme ve çalma uygulaması.

## Özellikler

- 🎵 YouTube'dan müzik arama ve çalma
- 📥 Çevrimdışı dinleme için müzik indirme
- 🌍 Çoklu dil desteği (TR, EN, DE, FR, ES, AR)
- 🎨 Modern Material 3 arayüzü
- 📱 Android optimized

## Desteklenen Diller

- 🇹🇷 Türkçe (TR)
- 🇬🇧 English (EN)
- 🇩🇪 Deutsch (DE)
- 🇫🇷 Français (FR)
- 🇪🇸 Español (ES)
- 🇸🇦 العربية (AR)

## Gereksinimler

- Flutter 3.22.0+
- Dart 3.2.0+
- Android SDK 21+

## Kurulum

```bash
# Bağımlılıkları indir
flutter pub get

# Localization oluştur
flutter gen-l10n

# Debug APK build
flutter build apk --debug

# Release APK build
flutter build apk --release
```

## Mimari

Proje Clean Architecture prensiplerine göre yapılandırılmıştır:

```
lib/
├── core/
│   ├── providers/       # State management
│   └── services/        # İş mantığı ve dış hizmetler
├── data/
│   └── repositories/    # Data layer
├── domain/
│   ├── entities/        # Model sınıfları
│   └── usecases/        # Use cases
├── presentation/
│   ├── app.dart         # App widget
│   ├── pages/           # Sayfalar
│   └── widgets/         # UI bileşenleri
└── l10n/                # Localization dosyaları
```

## Kullanılan Paketler

- **audio_service**: Müzik servis
- **just_audio**: Ses oynatıcı
- **youtube_explode_dart**: YouTube API
- **provider**: State management
- **permission_handler**: İzin yönetimi
- **path_provider**: File system erişimi

## Derleme (Build)

### Debug APK
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## CI/CD

GitHub Actions tarafından otomatik build yapılmaktadır. Her push veya pull request'te workflow tetiklenir.

### Build Artifact
- Başarılı buildler: [Actions](../../actions) sekmesinde bulunabilir
- APK download: Artifacts bölümünden indirebilirsiniz

## Geliştirme

Yeni özellik eklemek veya hata düzeltmek istiyorsanız:

1. Yeni branch oluşturun: `git checkout -b feature/yeni-ozellik`
2. Değişiklikleri yapın
3. Commit edin: `git commit -am 'Yeni özellik: ...'`
4. Push edin: `git push origin feature/yeni-ozellik`
5. Pull Request açın

## Lisans

Bu proje MIT Lisansı altında yayınlanmaktadır.

## Yapım

Vera Music - 2026
