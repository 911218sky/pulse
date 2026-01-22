import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';

/// Mini player bar shown at the bottom of screens when audio is playing
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen:
          (previous, current) =>
              previous.currentAudio != current.currentAudio ||
              previous.isPlaying != current.isPlaying ||
              previous.position != current.position ||
              previous.duration != current.duration ||
              previous.status != current.status,
      builder: (context, state) {
        // Don't show if no audio loaded
        if (state.currentAudio == null ||
            state.status == PlayerStatus.initial ||
            state.status == PlayerStatus.stopped) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar at top
                _ProgressIndicator(progress: state.progress, isDark: isDark),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      // Track info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.currentAudio!.title,
                              style: TextStyle(
                                color:
                                    isDark ? AppColors.white : AppColors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.currentAudio!.artist ?? 'Unknown Artist',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? AppColors.gray400
                                        : AppColors.gray600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play/Pause button
                      _PlayPauseButton(
                        isPlaying: state.isPlaying,
                        isDark: isDark,
                        onPressed: () {
                          if (state.isPlaying) {
                            context.read<PlayerBloc>().add(const PlayerPause());
                          } else {
                            context.read<PlayerBloc>().add(const PlayerPlay());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
    value: progress.clamp(0.0, 1.0),
    minHeight: 2,
    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
  );
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isDark,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    icon: Icon(
      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
      color: isDark ? AppColors.white : AppColors.black,
      size: 32,
    ),
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  );
}
