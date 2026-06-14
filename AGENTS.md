# Pulse Agent Guide

These instructions apply to all work inside this repository.

## Project Overview

Pulse is a cross-platform local music player built with Flutter. It targets Windows, macOS, Linux, and Android.

Core responsibilities:
- Local audio playback for MP3, FLAC, WAV, AAC, and OGG files
- Background playback with Android/system media controls
- Folder scanning, library import, and playlist management
- Persistent playback position, settings, playlists, and library data
- Minimal Vercel-inspired UI with black/white surfaces and blue accent color

## Required Workflow

- Check `git status --short` before editing.
- Do not revert unrelated user changes.
- Use `apply_patch` for manual file edits.
- Prefer `find`/`grep` if `rg` is unavailable in this environment.
- Keep `.codegraph/` local-only. Never commit it.
- Do not commit generated build/cache folders such as `.dart_tool/`, `build/`, platform `ephemeral/`, or `android/local.properties`.

## CodeGraph

This repository may contain a local `.codegraph/` index. Use it for code-impact work when available, but treat source files as authoritative.

Rules:
- Before non-trivial code edits, inspect definitions, references, callers, and dependencies for the symbols being changed.
- For bug fixes, check both upstream event sources and downstream consumers instead of only the failing line.
- For refactors, inspect public APIs and all call sites before changing names, signatures, or file locations.
- Use plain text search for Markdown, YAML, shell, generated files, localization strings, and simple config checks.
- If the graph looks stale after edits, branch changes, or file moves, refresh it locally only.
- Never stage, commit, push, or upload `.codegraph/`.

If Flutter/Dart are not on `PATH` in this workspace, use:
- `/home/sbplab/sky/.tools/flutter/flutter/bin/dart`
- `/home/sbplab/sky/.tools/flutter/flutter/bin/flutter`

## Verification

After editing Dart files, run:
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`

If Android build logic, manifest, signing, media service, or release packaging changes, also verify with an Android release build when the Android SDK is available:
- `flutter build apk --release`

If local Android SDK is unavailable, state that explicitly and rely on GitHub Actions release verification after pushing a tag.

After pushing a release tag, verify:
- The release workflow completed successfully.
- Android artifacts include `pulse-android-universal`, `pulse-android-arm64-v8a`, `pulse-android-armeabi-v7a`, `pulse-android-x86_64`, and `pulse-android-bundle`.
- `pulse-android-universal.apk` is present for normal Android users.

## Architecture

Follow the existing Clean Architecture layout:
- `lib/core/`: shared constants, DI, localization, routing, theme, utilities
- `lib/data/`: database, datasources, models, platform/service implementations
- `lib/domain/`: entities and repository interfaces
- `lib/presentation/`: BLoCs, screens, reusable widgets

Rules:
- Keep business entities in `domain`, persistence models in `data`, and widgets/BLoCs in `presentation`.
- Do not let presentation widgets call Drift/database APIs directly.
- Prefer repository interfaces across layer boundaries.
- Keep audio playback ownership app-lifetime where Android background controls depend on it.

## Android Update Safety

End users must be able to install future APKs over previous releases without uninstalling.

Do not change these unless intentionally planning a breaking migration:
- `applicationId = "dev.pulse.app"`
- Android namespace/package assumptions used by `AndroidManifest.xml`
- Release signing key/secrets used by GitHub Actions

Always bump `pubspec.yaml` version for releases:
- `versionName` should increase, for example `0.1.12`
- `versionCode` must increase monotonically, for example `+12`

For normal APK updates to work:
- Use the same Android signing key as previous release artifacts.
- Keep `versionCode` higher than the installed version.
- Keep the same `applicationId`.

If signing key or applicationId changes, Android treats it as a conflicting or different app and users may need to uninstall, which can delete app data.

If a user reports `App not installed as package conflicts`, check these first:
- They installed a different package id before this release.
- The APK was signed with a different key from the installed copy.
- The new APK has a lower or equal `versionCode`.
- They downloaded the wrong artifact for their device; default them to `pulse-android-universal.apk`.

## Persistence And Migration

The app stores data in Drift SQLite at `pulse.db` under the app documents directory.

Preserve user data across upgrades:
- Do not rename or delete tables without a migration.
- Do not reset `schemaVersion`.
- Add Drift migrations in `AppDatabase.migration` for schema changes.
- Never clear library, playlists, settings, playback state, or file positions during normal startup or upgrade.
- Keep audio file path canonicalization consistent; changing it can affect duplicate detection and saved positions.
- Test migrations with an existing database whenever schema, path normalization, playlist relations, or playback-state storage changes.

Destructive actions must stay explicit and user-confirmed through a shared confirmation dialog.

## Playback And Android Media Controls

The Android notification/lock-screen controls depend on `audio_service` and `MusicPlayerAudioHandler`.

Rules:
- Do not dispose the media player from transient UI/BLoC lifecycle events if the Android media session can still expose controls.
- `onTaskRemoved()` must not leave a notification/media session pointing at a disposed player.
- Do not map every `playing=false` stream event to `paused`; preserve `stopped`, `loading`, `initial`, and `error` when appropriate.
- Keep skip/seek/play/pause behavior synchronized between `PlayerBloc`, `AudioRepositoryImpl`, and `MusicPlayerAudioHandler`.
- Add regression tests for playback state transitions when fixing media-control bugs.

## Import And Playlist Duplicate Rules

Repeated imports must not create duplicate songs or repeatedly rewrite unchanged playlists.

Rules:
- Compare audio paths using `AudioPathUtils.canonicalize`.
- Rely on database uniqueness for `audio_files.filePath`, but also avoid no-op repository writes.
- When adding files to an existing playlist, filter out paths already present before dispatching updates.
- If `Playlist.addFile` or `Playlist.addFiles` returns the same instance, repository code should avoid persisting unchanged data.

## UI And Design System

Use the shared design tokens:
- `AppColors` for colors
- `AppSpacing` for spacing and radii
- `AppTypography` for text styles
- theme helpers from `core/theme/` where available

Prefer shared components:
- `VercelButton`
- `VercelCard`
- `VercelListTile`
- `VercelTextField`
- `AppToast`
- `AppConfirmDialog`

Avoid:
- hard-coded colors such as `Color(0xFF000000)` in widgets
- repeated hand-built dialogs
- one-off tile/card/button styling when an existing common widget fits
- adding user-facing strings without localization

The visual style should remain minimal, high-contrast, and consistent with the existing black/white/blue Vercel-inspired language.

## Localization

All user-facing strings should come from `AppLocalizations`.

When adding strings:
- update the relevant localization ARB/source files
- keep zh_TW and en coverage aligned
- avoid hard-coded UI strings except temporary debug logs

## Git And Release

Commit style in this repository uses emoji-prefixed conventional commits:
- `🐛 fix(scope): description`
- `✨ feat(scope): description`
- `📝 docs(scope): description`
- `♻️ refactor(scope): description`
- `⚡ perf(scope): description`
- `✅ test(scope): description`
- `🔧 chore(scope): description`
- `👷 ci(scope): description`
- `📦 build(scope): description`

Release flow:
- Commit changes to `main` only after checks pass.
- Tag releases as `vX.Y.Z`.
- Pushing a `v*` tag triggers the release workflow.
- Verify GitHub Actions after pushing release tags.

For Android users, recommend the universal APK unless they know their CPU ABI:
- `pulse-android-universal.apk`
