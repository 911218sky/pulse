$ErrorActionPreference = 'Stop'
# Native stderr from sdkmanager is noisy under Java 25; run package steps via cmd.exe.

$sdkRoot = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$cmdToolsZip = Join-Path $env:TEMP 'cmdline-tools-win.zip'
$extractRoot = Join-Path $env:TEMP 'cmdline-tools-win-extract'
$cmdToolsUrl = 'https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip'
$sdkManager = Join-Path $sdkRoot 'cmdline-tools\latest\bin\sdkmanager.bat'

function Ensure-CommandLineTools {
    if (Test-Path $sdkManager) {
        Write-Output "cmdline-tools already installed at $sdkManager"
        return
    }

    Write-Output "Downloading cmdline-tools..."
    if (Test-Path $cmdToolsZip) { Remove-Item $cmdToolsZip -Force }
    if (Test-Path $extractRoot) { Remove-Item $extractRoot -Recurse -Force }

    & curl.exe -L --retry 5 --retry-delay 3 --connect-timeout 30 -o $cmdToolsZip $cmdToolsUrl
    if ($LASTEXITCODE -ne 0) { throw "curl download failed with exit code $LASTEXITCODE" }

    $zipSize = (Get-Item $cmdToolsZip).Length
    Write-Output "Downloaded zip size: $([math]::Round($zipSize / 1MB, 2)) MB"
    if ($zipSize -lt 50MB) { throw "Downloaded zip looks too small ($zipSize bytes)" }

    Write-Output "Extracting cmdline-tools..."
    Expand-Archive -Path $cmdToolsZip -DestinationPath $extractRoot -Force

    $sourceDir = Join-Path $extractRoot 'cmdline-tools'
    $sourceSdkManager = Join-Path $sourceDir 'bin\sdkmanager.bat'
    if (-not (Test-Path $sourceSdkManager)) {
        throw "Expected sdkmanager.bat at $sourceSdkManager but it was not found"
    }

    $targetDir = Join-Path $sdkRoot 'cmdline-tools\latest'
    if (Test-Path $targetDir) { Remove-Item $targetDir -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -Path (Join-Path $sourceDir '*') -Destination $targetDir -Recurse -Force

    if (-not (Test-Path $sdkManager)) {
        throw "Install verification failed: $sdkManager missing"
    }

    Write-Output "cmdline-tools installed successfully"
}

New-Item -ItemType Directory -Force -Path $sdkRoot | Out-Null
Ensure-CommandLineTools

$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot
$env:Path = @(
    (Join-Path $sdkRoot 'cmdline-tools\latest\bin'),
    (Join-Path $sdkRoot 'platform-tools'),
    (Join-Path $sdkRoot 'emulator'),
    $env:Path
) -join ';'

Write-Output "Accepting SDK licenses..."
cmd /c "for /l %i in (1,1,20) do @echo y| sdkmanager --sdk_root=$sdkRoot --licenses" | Select-Object -Last 15

$packages = @(
    'platform-tools',
    'emulator',
    'platforms;android-35',
    'platforms;android-36',
    'build-tools;35.0.0',
    'build-tools;28.0.3',
    'system-images;android-35;google_apis;x86_64'
)

Write-Output "Installing SDK packages: $($packages -join ', ')"
cmd /c "sdkmanager --sdk_root=$sdkRoot $($packages -join ' ')" | Select-Object -Last 30

Write-Output "Installed SDK components:"
Get-ChildItem $sdkRoot | Select-Object Name

Write-Output "sdkmanager location: $sdkManager"
Write-Output "adb location:"
Get-Command adb -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
