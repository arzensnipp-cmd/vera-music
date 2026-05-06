<#
.SYNOPSIS
    Flutter SDK installer for Windows.
.DESCRIPTION
    Downloads the latest stable Flutter SDK, installs it to C:\src\flutter,
    updates the current user's PATH, and runs Flutter doctor with Android license acceptance.
.NOTES
    Run this script from an elevated PowerShell if you want to ensure it can write to C:\src.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installRoot = 'C:\src'
$installDir = Join-Path $installRoot 'flutter'
$tempZip = Join-Path $env:TEMP 'flutter_windows_stable.zip'
$tempExtract = Join-Path $env:TEMP 'flutter_install_temp'
$manifestUrl = 'https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json'

function Write-Log {
    param([string]$Message)
    Write-Host "[Flutter Installer] $Message"
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

Write-Log 'Başlatılıyor...'

Ensure-Directory -Path $installRoot

Write-Log 'Release manifest indiriliyor...'
$manifest = Invoke-RestMethod -Uri $manifestUrl -UseBasicParsing
$currentStableHash = $manifest.current_release.stable
$release = $manifest.releases | Where-Object { $_.hash -eq $currentStableHash }
if (-not $release) {
    throw 'Stable Flutter sürümü manifestinde bulunamadı.'
}

$archive = $release.archive
$downloadUrl = "$($manifest.base_url)/windows/$archive"

Write-Log "Flutter SDK indiriliyor: $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing

Write-Log 'Geçici dizin hazırlanıyor...'
if (Test-Path $tempExtract) {
    Remove-Item -Path $tempExtract -Recurse -Force
}
New-Item -ItemType Directory -Path $tempExtract | Out-Null

Write-Log 'Flutter SDK çıkarılıyor...'
Expand-Archive -LiteralPath $tempZip -DestinationPath $tempExtract -Force

$extractedFlutter = Join-Path $tempExtract 'flutter'
if (-not (Test-Path $extractedFlutter)) {
    throw 'Çıkarılan Flutter klasörü bulunamadı.'
}

if (Test-Path $installDir) {
    Write-Log 'Önceki Flutter kurulumu kaldırılıyor...'
    Remove-Item -Path $installDir -Recurse -Force
}

Move-Item -Path $extractedFlutter -Destination $installDir

Write-Log "Flutter SDK kuruldu: $installDir"

$flutterBin = Join-Path $installDir 'bin'
$currentUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not $currentUserPath) {
    $currentUserPath = ''
}

if ($currentUserPath -notmatch [regex]::Escape($flutterBin)) {
    $newUserPath = if ($currentUserPath.Trim()) { "$currentUserPath;$flutterBin" } else { $flutterBin }
    [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
    Write-Log "PATH güncellendi: $flutterBin"
} else {
    Write-Log 'Flutter zaten kullanıcı PATH içinde.'
}

$env:Path = "$flutterBin;$env:Path"

Write-Log 'Flutter sürümü kontrol ediliyor...'
& "$flutterBin\flutter.bat" --version

Write-Log 'Flutter doctor çalıştırılıyor...'
& "$flutterBin\flutter.bat" doctor

Write-Log 'Android lisansları için onaylama başlatılıyor...'
Write-Host ''
Write-Host 'Lütfen tüm Android lisanslarını kabul etmek için ekranda çıkan soruları onaylayın.' -ForegroundColor Yellow
Write-Host ''
& "$flutterBin\flutter.bat" doctor --android-licenses

Write-Log 'Kurulum tamamlandı.'
Write-Host ''
Write-Host 'Yeni PATH değişikliklerinin geçerli olması için bu PowerShell penceresini kapatıp tekrar açın.' -ForegroundColor Green
Write-Host 'Sonrasında proje dizinine giderek `flutter pub get` çalıştırabilirsiniz.' -ForegroundColor Green
