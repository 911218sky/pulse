# Pulse UI Design System

Pulse UI is **Spotify-inspired** dark music chrome: charcoal surfaces, artwork-forward rows, pill search, and a floating mini player — with Pulse’s own blue accent (not Spotify Green).

Primary pattern references (visual roles only; do not clone brand marks):
- Spotify Android / web listening chrome (charcoal stack, dense track rows, floating mini player)
- [Spotify partner design guidelines](https://developer.spotify.com/documentation/design) (artwork rounding, platform fonts)

## Goals

- Dark-first charcoal canvas so artwork and titles pop
- One functional accent (`#0070F3`) for play / now-playing / primary CTAs
- Pill search and circular play; dense inset track lists
- Shared Flutter tokens so screens stay consistent

## Color

Implemented in `lib/core/constants/colors.dart` and `lib/core/theme/app_theme_tokens.dart`.

| Role | Dark | Light |
|------|------|-------|
| Page background | `#121212` | `#FFFFFF` |
| Surface / card | `#181818` | `#F5F5F5` |
| Interactive fill | `#1F1F1F` | `#EEEEEE` |
| Elevated (mini player, menus) | `#282828` | `#FFFFFF` |
| Default border | `#292929` | `#EAEAEA` |
| Primary text | `#FFFFFF` | `#000000` |
| Secondary text | `#B3B3B3` | `#6A6A6A` |
| Accent / CTAs | `#0070F3` | `#0070F3` |
| Accent hover | `#3291FF` | `#3291FF` |
| Error | `#EE0000` | `#EE0000` |

Rules:
- Prefer `context.appPalette` over raw `Color(0xFF…)`.
- Use accent sparingly (play CTA, now-playing title, primary actions).
- **Never** ship Spotify Green (`#1DB954` / `#1ED760`) as Pulse brand color.
- Elevation is brightness steps (charcoal layers), not heavy Material shadows.

## Spacing and radius

Implemented in `lib/core/constants/spacing.dart`:

| Token | Value | Use |
|-------|-------|-----|
| `radiusArt` | `4` | Album / track art |
| `radiusSm` / `radiusMd` | `8` | Cards, controls |
| `radiusLg` | `12` | Mini player, menus |
| `radiusXl` | `16` | Sheets |
| `radiusFull` / pill | `9999` | Search field, primary CTA |
| spacing scale | `4 / 8 / 12 / 16 / 24 / 32 / 48` | 8px grid + art→text gap `12` |

## Typography

Implemented in `lib/core/constants/typography.dart`.

- Family: `Inter` (platform sans; do not use SpotifyMix / Circular)
- Hierarchy via weight (400 vs 700) more than huge size jumps
- Track titles ~14–16; metadata ~12–13 secondary
- Time labels: tabular figures

## Shared components

Prefer these over one-off Material widgets:

| Widget | Path | Notes |
|--------|------|-------|
| `VercelButton` | `lib/presentation/widgets/common/vercel_button.dart` | primary / secondary / ghost / danger (pill primary) |
| `VercelCard` / `VercelListTile` | `lib/presentation/widgets/common/vercel_card.dart` | `inset` for music rows |
| `VercelTextField` | `lib/presentation/widgets/common/vercel_text_field.dart` | pill search fill |
| `AppScreenHeader` | `lib/presentation/widgets/common/app_screen_header.dart` | flat page title chrome |
| `AppEmptyState` | `lib/presentation/widgets/common/app_empty_state.dart` | title + subtitle + one CTA |
| `AppConfirmDialog` | `lib/presentation/widgets/common/app_confirm_dialog.dart` | destructive confirms |
| `AppToast` | `lib/presentation/widgets/common/app_toast.dart` | feedback |

- Music library rows: `VercelListTileStyle.inset` with leading art (~48–52), not bordered cards.
- Now-playing: accent / bold title + equalizer — never a filled selection block.
- Mini player: floating elevated bar, bottom progress, rounded art.

## Chrome patterns (Spotify → Pulse)

| Spotify-like pattern | Pulse mapping |
|----------------------|---------------|
| Charcoal canvas `#121212` | `AppColors.darkBackground` / `appPalette.background` |
| Pill search | `VercelTextField` with `radiusFull` + interactive fill |
| Dense track rows | `VercelListTile` inset + art leading |
| Floating mini player | `MiniPlayer` elevated + margin, progress on bottom edge |
| Circular play | `PlaybackControls` / mini play button |
| Accent for play / active | Pulse `#0070F3` (not Spotify green) |

## Do / don't

Do:
- Keep dark charcoal layers; let artwork supply color when available
- Keep destructive actions secondary (overflow / confirm dialog)
- Reuse tokens and shared widgets first

Don't:
- Copy Spotify Green, logo, or proprietary fonts
- Add purple gradients, glassmorphism, or multi-layer neon glows
- Invent new radii or gray ramps per screen
- Mix Material FAB / filled buttons when `VercelButton` fits

## Verification

After UI token or shared-widget changes:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Visually check dark + light: home list, search pill, empty state, mini player, full player.
