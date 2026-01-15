---
inclusion: always
---

# Pulse - Project Conventions

## What is Pulse?

Pulse is a cross-platform local music player built with Flutter. It features a Vercel-inspired minimalist design with a black/white color scheme and blue accents (#0070F3).

**Target Platforms:** Windows, macOS, Linux, Android

**Core Features:**
- Local audio file playback (MP3, FLAC, WAV, AAC, OGG)
- Background playback with system media controls
- Folder scanning and music library management
- Sleep timer
- Dark/Light theme
- Multi-language support (zh_TW, en)

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.24+ / Dart 3.7+ |
| State Management | flutter_bloc |
| Database | Drift (SQLite) |
| Audio Engine | media_kit + audio_service |
| Routing | go_router |
| Dependency Injection | get_it |

## Architecture

This project follows Clean Architecture with three layers:

```
lib/
├── core/                    # Shared utilities
│   ├── constants/           # Colors, spacing, typography
│   ├── di/                  # Service locator setup
│   ├── l10n/                # Localization
│   ├── router/              # Route definitions
│   └── theme/               # ThemeData configuration
│
├── data/                    # Data layer (implementations)
│   ├── database/            # Drift tables and DAOs
│   ├── datasources/         # Local/remote data sources
│   ├── models/              # Data models (JSON serializable)
│   └── services/            # Audio handler, file scanner
│
├── domain/                  # Domain layer (abstractions)
│   ├── entities/            # Business entities
│   └── repositories/        # Repository interfaces
│
└── presentation/            # UI layer
    ├── bloc/                # BLoC classes (events, states, bloc)
    ├── screens/             # Full-page widgets
    └── widgets/             # Reusable UI components
```

## Design System

### Colors

Always use `AppColors` from `core/constants/colors.dart`:

```dart
// ✅ Correct
Container(color: AppColors.darkBackground)

// ❌ Wrong - never hardcode colors
Container(color: Color(0xFF000000))
```

Key colors:
- Background: `#000000` (dark) / `#FFFFFF` (light)
- Surface: `#111111` (dark) / `#FAFAFA` (light)
- Accent: `#0070F3`
- Border: `#333333` (dark) / `#EAEAEA` (light)

### Spacing

Always use `AppSpacing` from `core/constants/spacing.dart`:

```dart
// ✅ Correct
Padding(padding: EdgeInsets.all(AppSpacing.md))

// ❌ Wrong - never hardcode spacing
Padding(padding: EdgeInsets.all(16))
```

### Typography

Use `AppTypography` for text styles to maintain consistency.

## Coding Standards

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `AudioPlayer` |
| Variables/Functions | camelCase | `playTrack()` |
| Files/Folders | snake_case | `audio_player.dart` |
| BLoC Events | PascalCase + Verb | `PlaybackStarted` |
| BLoC States | PascalCase + Adjective | `PlaybackPlaying` |
| Constants | camelCase | `defaultVolume` |

### Widget Guidelines

```dart
class TrackListItem extends StatelessWidget {
  const TrackListItem({
    super.key,
    required this.track,
    this.onTap,
  });

  final Track track;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Use context.watch for reactive rebuilds
    final isPlaying = context.watch<PlayerBloc>().state.isPlaying;
    
    // Use context.read for one-time access (event dispatch)
    return GestureDetector(
      onTap: () => context.read<PlayerBloc>().add(TrackSelected(track)),
      child: Container(),
    );
  }
}
```

Rules:
- Always use `const` constructors when possible
- Declare fields as `final`
- Use `super.key` instead of `Key? key`
- Prefer `context.watch/read` over `BlocProvider.of`

### BLoC Guidelines

```dart
// Events - use sealed class
sealed class PlayerEvent {}

final class PlayerPlayPressed extends PlayerEvent {}

final class PlayerTrackChanged extends PlayerEvent {
  PlayerTrackChanged(this.track);
  final Track track;
}

// States - use Equatable
final class PlayerState extends Equatable {
  const PlayerState({
    this.status = PlayerStatus.idle,
    this.currentTrack,
  });

  final PlayerStatus status;
  final Track? currentTrack;

  PlayerState copyWith({
    PlayerStatus? status,
    Track? currentTrack,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentTrack: currentTrack ?? this.currentTrack,
    );
  }

  @override
  List<Object?> get props => [status, currentTrack];
}
```

### Localization

All user-facing strings must use `AppLocalizations`:

```dart
// ✅ Correct
Text(AppLocalizations.of(context).playButton)

// ❌ Wrong - never hardcode strings
Text('Play')
```

## Git Conventions

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code formatting (no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Adding tests
- `chore`: Build/tooling changes

Examples:
```
feat(player): add sleep timer functionality
fix(scanner): handle permission denied on Android 14
refactor(bloc): migrate to sealed class events
```

### Branch Naming

- `main` - Stable release
- `develop` - Development
- `feature/<name>` - New features
- `fix/<name>` - Bug fixes
- `refactor/<name>` - Refactoring

## Testing

```
test/
├── unit/           # Pure Dart logic tests
├── widget/         # Widget tests
└── bloc/           # BLoC tests using bloc_test
```

Use `mocktail` for mocking dependencies.

## Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, initializes audio service and database |
| `lib/core/di/service_locator.dart` | Dependency injection setup |
| `lib/core/router/app_router.dart` | Route definitions |
| `lib/data/database/app_database.dart` | Drift database schema |
| `lib/data/services/audio_handler.dart` | Background audio handling |
