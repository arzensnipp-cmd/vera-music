# GitHub'a Upload Talimatları

## Adım 1: Git Kur

Windows'ta Git kurmanız gereklidir:

**Seçenek A: Git Command Line (Önerilen)**
1. https://git-scm.com/download/win adresinden Git for Windows indir
2. Default ayarlarla kur (Next > Next > Install)
3. PowerShell'i yeniden aç

**Seçenek B: GitHub Desktop**
1. https://desktop.github.com adresinden GitHub Desktop indir
2. Kur ve GitHub hesabınla giriş yap

## Adım 2: GitHub'da Yeni Repository Oluştur

1. https://github.com/new adresine git
2. Repository adı: `vera-music`
3. Açıklamა: `Vera Music Beta - YouTube tabanlı müzik indirme uygulaması`
4. **Public** seç (önemli!)
5. `.gitignore` ve `README.md`'yi ekleme (zaten tekil dosyalar var)
6. **Create repository** tıkla

GitHub size bir URL verecek:
```
https://github.com/KULLANICI_ADIN/vera-music.git
```

## Adım 3: Terminalde Git Setup (PowerShell/CMD)

```powershell
# İlk kez git kullanıyorsanız - config ayarla
git config --global user.name "İsim Soyisim"
git config --global user.email "email@example.com"

# Proje dizinine git
cd c:\Users\hango\Desktop\vera music

# Git repository başlat
git init

# Tüm dosyaları ekle
git add .

# İlk commit
git commit -m "Initial commit: Vera Music Beta setup with GitHub Actions"

# GitHub repository'yi remote olarak ekle
# (URL'yi GitHub'dan kopyala)
git remote add origin https://github.com/KULLANICI_ADIN/vera-music.git

# main branch'e yeniden isimlendir
git branch -M main

# GitHub'a push et
git push -u origin main
```

## Adım 4: GitHub Actions Workflow'ınız Çalışmaya Başlayacak

Push yaptığınız an:
1. GitHub Actions otomatik tetiklenir
2. Ubuntu VM'de Flutter build başlar
3. 5-10 dakika içinde APK hazır olur

### Build Status Kontrol Etme

1. GitHub repository sayfasında gren "Actions" sekmesine tıkla
2. "Build Flutter APK" workflow'unu aç
3. Green ✅ işareti = BUILD BAŞARILI
4. İçinde "Artifacts" bölümü altında `app-debug` indir

## Adım 5: APK İndir

Build tamamlandıktan sonra:
1. Actions > Build Flutter APK > En son build
2. **Artifacts** sekmesi açılır
3. `app-debug` ZIP'ini indir (içinde app-debug.apk var)
4. Telefonunuza taşı ve yükle

## Troubleshooting

### Hata: "Permission denied"
- GitHub'da Personal Access Token oluştur: https://github.com/settings/tokens
- `git push` yaparken token'ı password olarak gir

### Build Hatası
- GitHub Actions > Build sekmesinde hatayı gör
- Genellikle: AndroidManifest.xml veya gradle hataları
- Lokal olarak yapılan düzeltmeleri commit et ve push et, Actions otomatik yeniden çalışır

### APK Download Linki
```
https://github.com/KULLANICI_ADIN/vera-music/actions
```

## Sonraki Pushlar

İlk sefer sonra her push otomatik build yapacak:

```powershell
# Değişiklik yap (kod, dil dosyası, vb.)

# Değişiklikleri ekle
git add .

# Commit
git commit -m "Açıklayıcı mesaj"

# Push
git push
```

Bu kadar. 5 dakika sonra Actions'de yeni APK hazır!
