import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';

/// Floating mini player — Spotify-inspired elevated bar with bottom progress.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;

    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen:
          (previous, current) =>
              previous.currentAudio != current.currentAudio ||
              previous.isPlaying != current.isPlaying ||
              previous.duration != current.duration ||
              previous.status != current.status,
      builder: (context, state) {
        if (state.currentAudio == null ||
            state.status == PlayerStatus.initial ||
            state.status == PlayerStatus.stopped) {
          return const SizedBox.shrink();
        }

        final artworkPath = state.currentAudio!.artworkPath;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Material(
              color: palette.elevatedSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: AppSpacing.miniPlayerHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onTap,
                                  child: Row(
                                    children: [
                                      _MiniArt(
                                        artworkPath: artworkPath,
                                        palette: palette,
                                      ),
                                      const SizedBox(
                                        width: AppSpacing.artTextGap,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              state.currentAudio!.title,
                                              style: AppTypography.labelLarge(
                                                palette.primaryText,
                                              ).copyWith(
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              state.currentAudio!.artist ??
                                                  l10n.unknownArtist,
                                              style: AppTypography.bodySmall(
                                                palette.secondaryText,
                                              ).copyWith(
                                                decoration: TextDecoration.none,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            BlocBuilder<PlaylistBloc, PlaylistState>(
                              buildWhen:
                                  (previous, current) =>
                                      previous.hasPrevious !=
                                          current.hasPrevious ||
                                      previous.hasNext != current.hasNext ||
                                      previous.currentTrackIndex !=
                                          current.currentTrackIndex,
                              builder:
                                  (context, playlistState) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _TransportButton(
                                        icon: Icons.skip_previous_rounded,
                                        enabled: playlistState.hasPrevious,
                                        onPressed: () {
                                          context.read<PlaylistBloc>().add(
                                            const PlaylistPlayPrevious(),
                                          );
                                        },
                                      ),
                                      _PlayPauseButton(
                                        isPlaying: state.isPlaying,
                                        onPressed: () {
                                          if (state.isPlaying) {
                                            context.read<PlayerBloc>().add(
                                              const PlayerPause(),
                                            );
                                          } else {
                                            context.read<PlayerBloc>().add(
                                              const PlayerPlay(),
                                            );
                                          }
                                        },
                                      ),
                                      _TransportButton(
                                        icon: Icons.skip_next_rounded,
                                        enabled: playlistState.hasNext,
                                        onPressed: () {
                                          context.read<PlaylistBloc>().add(
                                            const PlaylistPlayNext(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    BlocBuilder<PlayerBloc, PlayerState>(
                      buildWhen:
                          (previous, current) =>
                              previous.position != current.position ||
                              previous.duration != current.duration,
                      builder:
                          (context, progressState) => SizedBox(
                            height: AppSpacing.progressBarHeight,
                            width: double.infinity,
                            child: LinearProgressIndicator(
                              value: progressState.progress.clamp(0.0, 1.0),
                              backgroundColor: palette.subtleBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppColors.white : AppColors.accent,
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniArt extends StatelessWidget {
  const _MiniArt({required this.artworkPath, required this.palette});

  final String? artworkPath;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    const size = AppSpacing.miniPlayerArtSize;
    final radius = BorderRadius.circular(AppSpacing.radiusArt);

    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.interactive,
        borderRadius: radius,
      ),
      child: Icon(Icons.music_note_rounded, color: palette.mutedText, size: 18),
    );

    if (artworkPath == null || artworkPath!.isEmpty) {
      return SizedBox(width: size, height: size, child: placeholder);
    }

    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(artworkPath!),
          fit: BoxFit.cover,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
          errorBuilder: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: isDark ? AppColors.white : AppColors.black,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: isDark ? AppColors.black : AppColors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({
    required this.icon,
    required this.onPressed,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 22,
          color: enabled ? palette.primaryText : palette.disabledText,
        ),
      ),
    );
  }
}
