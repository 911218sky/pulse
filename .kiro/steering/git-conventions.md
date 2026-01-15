# Git Commit Conventions

## Commit Message Format

All commits must follow this format with emoji icons:

```
<emoji> <type>(<scope>): <description>
```

## Commit Types with Icons

| Type | Emoji | Description |
|------|-------|-------------|
| feat | ✨ | New feature |
| fix | 🐛 | Bug fix |
| docs | 📝 | Documentation changes |
| style | 💄 | Code formatting (no logic change) |
| refactor | ♻️ | Code refactoring |
| perf | ⚡ | Performance improvement |
| test | ✅ | Adding or updating tests |
| chore | 🔧 | Build/tooling/config changes |
| ci | 👷 | CI/CD changes |
| build | 📦 | Build system changes |
| revert | ⏪ | Revert previous commit |
| init | 🎉 | Initial commit |
| deps | ⬆️ | Dependency updates |
| remove | 🔥 | Remove code or files |
| move | 🚚 | Move or rename files |
| wip | 🚧 | Work in progress |

## Examples

```bash
✨ feat(player): add sleep timer functionality
🐛 fix(scanner): handle permission denied on Android 14
📝 docs(readme): add app icon
♻️ refactor(bloc): migrate to sealed class events
⚡ perf(database): optimize query performance
✅ test(player): add unit tests for playback
🔧 chore(config): update analysis options
👷 ci(workflow): use latest stable Flutter
⬆️ deps: upgrade flutter_bloc to v9.2.0
🔥 remove(legacy): delete deprecated widgets
🚚 move(scripts): relocate PowerShell scripts
```

## Branch Strategy

- All development work goes to `develop` branch
- Only merge to `main` when features are stable and tested
- Use feature branches for larger changes: `feature/<name>`
- Use fix branches for bug fixes: `fix/<name>`

## Workflow

1. Always commit to `develop` branch during development
2. Test thoroughly on `develop`
3. When ready for release, merge `develop` into `main`
4. Tag releases on `main` branch (e.g., `v0.1.0`)

## Quick Reference

Copy-paste ready:
```
✨ feat():
🐛 fix():
📝 docs():
💄 style():
♻️ refactor():
⚡ perf():
✅ test():
🔧 chore():
👷 ci():
📦 build():
⬆️ deps:
🔥 remove():
🚚 move():
```
