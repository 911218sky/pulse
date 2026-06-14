# Pulse Repo Rules

## Scope

Use these instructions for work inside `pulse/`.

## Flutter Checks

- After editing Dart files, run `dart format --set-exit-if-changed .`
- After editing Dart files, run `flutter analyze`
- Fix any issues found before finishing

## Architecture

- Follow the existing Clean Architecture layout in `lib/`
- Keep data, domain, and presentation layers separated
- Prefer existing shared widgets and utilities over new one-off code

## UI Conventions

- Use `AppColors` instead of hard-coded colors
- Use `AppSpacing` instead of hard-coded spacing
- Use `AppTypography` for text styles
- Keep the Vercel-inspired black/white/blue visual language consistent
- Reuse common widgets from `lib/presentation/widgets/common/` when possible

## Localization

- User-facing strings should come from `AppLocalizations`

## Git Conventions

- Follow Conventional Commits
- Use the existing emoji-prefixed commit style in this repo

