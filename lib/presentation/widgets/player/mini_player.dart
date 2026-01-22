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
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Column(
              children: [
                // Progress bar at top
                SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: state.progress.clamp(0.0, 1.0),
                    backgroundColor:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        // Music icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.darkCard : AppColors.gray100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Track info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.currentAudio!.title,
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? AppColors.white
                                          : AppColors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
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
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Play/Pause button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
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
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: Icon(
                                state.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color:
                                    isDark ? AppColors.white : AppColors.black,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
