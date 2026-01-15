# Flutter Dependencies Upgrade Script
# Usage: .\upgrade_deps.ps1

Write-Host "Starting dependencies upgrade..." -ForegroundColor Cyan

# Show outdated packages
Write-Host "`nChecking outdated packages..." -ForegroundColor Yellow
flutter pub outdated

# Upgrade to latest compatible versions
Write-Host "`nUpgrading to latest compatible versions..." -ForegroundColor Yellow
flutter pub upgrade

# Upgrade to latest major versions
Write-Host "`nUpgrading to latest major versions..." -ForegroundColor Yellow
flutter pub upgrade --major-versions

# Regenerate code after upgrade
Write-Host "`nRegenerating code (build_runner)..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

Write-Host "`nUpgrade complete!" -ForegroundColor Green
Write-Host "Run 'flutter pub outdated' to check remaining updates." -ForegroundColor Cyan
