# Development Environment Setup

Pulse targets **Android**. You do **not** need Android Studio.

Minimum toolchain:

| Tool | Why |
| --- | --- |
| Flutter (stable) | App framework. This repo is verified with **3.47.5**. |
| JDK **17** | Android Gradle builds |
| Android SDK (cmdline-tools) | `platform-tools` (`adb`), platforms, build-tools |

Optional:

- A physical Android phone with USB debugging, **or**
- Android Emulator (large download; only if you want a virtual device)

Dart must be `3.7.2+` (comes with Flutter).

---

## Quick start (after tools are installed)

```bash
git clone https://github.com/911218sky/pulse.git
cd pulse
flutter pub get
flutter doctor
flutter run
```

Verification:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Release APK / bundle:

```bash
flutter build apk --release
flutter build appbundle --release
```

---

## Windows

### 1. Install Flutter

1. Download the stable SDK from [Flutter install (Windows)](https://docs.flutter.dev/get-started/install/windows/mobile).
2. Extract somewhere stable, for example `C:\src\flutter` or next to this repo (`..\sdk`).
3. Add `...\flutter\bin` to your **User** `PATH`.
4. Open a **new** terminal and check:

```powershell
flutter --version
flutter doctor
```

This repo’s VS Code / Cursor setting uses `"dart.flutterSdkPath": "../sdk"` when Flutter lives beside the project.

### 2. Install JDK 17

Install any JDK 17 (Microsoft Build of OpenJDK, Temurin, etc.), then point Flutter at it if needed:

```powershell
flutter config --jdk-dir="C:\Program Files\Microsoft\jdk-17.x.x.x-hotspot"
```

Use your real JDK path. Confirm with:

```powershell
java -version
flutter doctor -v
```

### 3. Install Android SDK (no Android Studio)

Pulse ships a helper script that installs Google’s **command-line tools** into:

`%LOCALAPPDATA%\Android\Sdk`

(= `C:\Users\<you>\AppData\Local\Android\Sdk` on most machines)

**Minimal (enough to build APKs + use `adb`):**

```powershell
cd pulse
powershell -ExecutionPolicy Bypass -File .\scripts\install_android_sdk.ps1 -Minimal
```

**Full (also emulator + a system image; multi‑GB):**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install_android_sdk.ps1
```

Then permanently set user environment variables (PowerShell):

```powershell
$sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdk, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', $sdk, 'User')

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$extra = @(
  (Join-Path $sdk 'platform-tools'),
  (Join-Path $sdk 'cmdline-tools\latest\bin')
)
foreach ($p in $extra) {
  if ($userPath -notlike "*$p*") { $userPath = "$p;$userPath" }
}
[Environment]::SetEnvironmentVariable('Path', $userPath, 'User')
```

Open a **new** terminal and verify **one** `adb`:

```powershell
where.exe adb
adb version
# Expect: ...\Android\Sdk\platform-tools\adb.exe
```

Avoid installing a second Platform-Tools via WinGet; Flutter will warn about multiple `adb` binaries.

### 4. Connect a device

- **Phone:** enable Developer options → USB debugging, plug in USB, accept the prompt, then `flutter devices`.
- **Emulator:** only if you ran the full SDK install; create/start an AVD, then `flutter devices`.

### 5. Run Pulse

```powershell
cd pulse
flutter pub get
flutter run
```

---

## Linux

### 1. Install Flutter

Follow [Flutter install (Linux)](https://docs.flutter.dev/get-started/install/linux/mobile), or:

```bash
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```

Install Linux desktop prerequisites only if you also want `linux` builds; for Android-only work they are optional.

### 2. Install JDK 17

Debian / Ubuntu:

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version
```

Fedora:

```bash
sudo dnf install -y java-17-openjdk-devel
```

### 3. Install Android SDK (no Android Studio)

Default SDK root used by the script: `~/Android/Sdk`

**Minimal:**

```bash
cd pulse
chmod +x scripts/install_android_sdk.sh
./scripts/install_android_sdk.sh --minimal
```

**Full (emulator + system image):**

```bash
./scripts/install_android_sdk.sh
```

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

Reload the shell, then:

```bash
which adb
adb version
# Expect: $HOME/Android/Sdk/platform-tools/adb
flutter doctor
```

On Linux you may also need `udev` rules for USB devices; see [Android device setup](https://developer.android.com/studio/run/device).

### 4. Run Pulse

```bash
cd pulse
flutter pub get
flutter run
```

---

## What the SDK scripts install

| Package | Minimal | Full |
| --- | --- | --- |
| `platform-tools` (`adb`) | yes | yes |
| `platforms;android-35` / `36` | yes | yes |
| `build-tools;35.0.0` (+ `28.0.3`) | yes | yes |
| `emulator` | no | yes |
| `system-images;android-35;google_apis;x86_64` | no | yes |

Licenses are accepted non-interactively via `sdkmanager --licenses`.

`adb` after a successful install:

- Windows: `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`
- Linux: `~/Android/Sdk/platform-tools/adb`

---

## Common issues

**`flutter doctor` wants Android Studio**  
You can ignore the Android Studio checkbox if cmdline-tools, platform-tools, licenses, and JDK 17 are fine.

**`cmdline-tools component is missing`**  
Re-run the install script, or install `cmdline-tools;latest` with `sdkmanager`.

**Multiple `adb` binaries (Windows)**  
Keep only `%LOCALAPPDATA%\Android\Sdk\platform-tools` on `PATH`. Uninstall WinGet `Google.PlatformTools` if present.

**`Android license status unknown`**

```bash
flutter doctor --android-licenses
```

**USB device not listed**  
Cable/drivers (Windows), authorize the PC on the phone, or check Linux `udev` rules. Try `adb devices`.

**CI / release note**  
GitHub Actions builds use Flutter **3.47.5** and JDK **17**. Matching those locally avoids surprise toolchain drift.

---

## Related files

- `scripts/install_android_sdk.ps1` — Windows SDK installer
- `scripts/install_android_sdk.sh` — Linux SDK installer
- `docs/UI.md` — UI design system
- `AGENTS.md` — agent / contributor workflow for this repo
