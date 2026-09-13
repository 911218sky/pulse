# Flutter Full Clean Script
# Usage: .\clean_flutter.ps1

Write-Host "Starting Flutter project cleanup..." -ForegroundColor Cyan

# Flutter clean
Write-Host "`nRunning flutter clean..." -ForegroundColor Yellow
flutter clean

# Clean Flutter global cache
Write-Host "`nCleaning Flutter pub cache..." -ForegroundColor Yellow
flutter pub cache clean

Write-Host "Repairing Flutter pub cache..." -ForegroundColor Yellow
flutter pub cache repair

# Remove build folder
if (Test-Path "build") {
    Write-Host "Removing build folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "build"
}

# Remove .dart_tool
if (Test-Path ".dart_tool") {
    Write-Host "Removing .dart_tool folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force ".dart_tool"
}

# Remove pubspec.lock
if (Test-Path "pubspec.lock") {
    Write-Host "Removing pubspec.lock..." -ForegroundColor Yellow
    Remove-Item -Force "pubspec.lock"
}

# Remove generated .g.dart files
Write-Host "Removing generated .g.dart files..." -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*.g.dart" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force

# Remove generated .freezed.dart files
Write-Host "Removing generated .freezed.dart files..." -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*.freezed.dart" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force

# Clean Android
if (Test-Path "android") {
    Write-Host "Cleaning Android..." -ForegroundColor Yellow
    if (Test-Path "android/.gradle") { Remove-Item -Recurse -Force "android/.gradle" }
    if (Test-Path "android/app/build") { Remove-Item -Recurse -Force "android/app/build" }
    if (Test-Path "android/build") { Remove-Item -Recurse -Force "android/build" }
}

# Get dependencies
Write-Host "`nGetting dependencies (flutter pub get)..." -ForegroundColor Yellow
flutter pub get

# Regenerate code
Write-Host "`nRegenerating code (build_runner)..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

Write-Host "`nCleanup complete!" -ForegroundColor Green
