# Contributing to Pulse

感謝你對 Pulse 的貢獻興趣！請閱讀以下指南。

## 開發環境

- Flutter 3.24.0+
- Dart 3.7.0+
- Android Studio / VS Code with Flutter extension

## 開始開發

```bash
git clone https://github.com/your-username/pulse.git
cd pulse
flutter pub get
flutter run
```

## 分支策略

| 分支 | 用途 |
|------|------|
| `main` | 穩定版本，僅接受 PR |
| `develop` | 開發分支 |
| `feature/*` | 新功能 |
| `fix/*` | Bug 修復 |
| `refactor/*` | 重構 |

## Commit 規範

使用 [Conventional Commits](https://www.conventionalcommits.org/)：

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Type

- `feat`: 新功能
- `fix`: Bug 修復
- `docs`: 文件更新
- `style`: 程式碼格式（不影響邏輯）
- `refactor`: 重構
- `perf`: 效能優化
- `test`: 測試相關
- `chore`: 建置/工具變更

### 範例

```
feat(player): add sleep timer functionality

- Add countdown timer with preset options
- Support custom duration input
- Auto-pause when timer ends

Closes #123
```

## Pull Request 流程

1. Fork 專案
2. 建立功能分支：`git checkout -b feature/amazing-feature`
3. 提交變更：`git commit -m 'feat: add amazing feature'`
4. 推送分支：`git push origin feature/amazing-feature`
5. 開啟 Pull Request

### PR 檢查清單

- [ ] 程式碼通過 `flutter analyze`
- [ ] 程式碼格式化 `dart format .`
- [ ] 新功能有對應測試
- [ ] 更新相關文件
- [ ] Commit message 符合規範

## 程式碼風格

### Dart/Flutter

遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 和專案 `analysis_options.yaml`。

```dart
// ✅ Good
class AudioPlayer {
  final AudioService _audioService;
  
  AudioPlayer(this._audioService);
  
  Future<void> play(Track track) async {
    await _audioService.play(track.uri);
  }
}

// ❌ Bad
class audio_player {
  var audioService;
  play(track) async {
    await audioService.play(track.uri);
  }
}
```

### 命名規範

| 類型 | 規範 | 範例 |
|------|------|------|
| 類別 | PascalCase | `AudioPlayer` |
| 變數/函數 | camelCase | `playTrack()` |
| 常數 | camelCase | `defaultVolume` |
| 檔案 | snake_case | `audio_player.dart` |
| 資料夾 | snake_case | `audio_service/` |

### 專案結構

```
lib/
├── core/           # 核心功能（主題、路由、常數）
├── data/           # 資料層（模型、資料源、服務）
├── domain/         # 領域層（實體、Repository 介面）
└── presentation/   # 展示層（畫面、Widget、BLoC）
```

## 問題回報

使用 GitHub Issues，請包含：

- 問題描述
- 重現步驟
- 預期行為
- 實際行為
- 環境資訊（OS、Flutter 版本）
- 截圖（如適用）

## 授權

貢獻的程式碼將採用 MIT 授權。
