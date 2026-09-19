import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';
import 'package:pulse/core/utils/time_parser.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_bloc.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_event.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_state.dart';
import 'package:pulse/presentation/widgets/common/animated_equalizer.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';
import 'package:pulse/presentation/widgets/player/playback_controls.dart';
import 'package:pulse/presentation/widgets/player/progress_bar.dart';
import 'package:pulse/presentation/widgets/player/time_input_dialog.dart';
import 'package:pulse/presentation/widgets/player/volume_slider.dart';
import 'package:pulse/presentation/widgets/sleep_timer/sleep_timer_dialog.dart';
import 'package:pulse/presentation/widgets/sleep_timer/sleep_timer_indicator.dart';

/// Full-screen player screen with enhanced visuals
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  String? _lastResumePromptKey;
  Timer? _resumePromptTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showResumePromptIfNeeded(context.read<PlayerBloc>().state);
    });
  }

  @override
  void dispose() {
    _resumePromptTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen:
          (prev, curr) =>
              prev.pendingResumePosition != curr.pendingResumePosition ||
              prev.currentAudio?.path != curr.currentAudio?.path,
      listener: (context, state) => _showResumePromptIfNeeded(state),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  isDark
                      ? const [
                        AppColors.darkElevated,
                        AppColors.darkBackground,
                        AppColors.darkBackground,
                      ]
                      : const [
                        AppColors.lightInteractive,
                        AppColors.lightBackground,
                        AppColors.lightBackground,
                      ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<PlayerBloc, PlayerState>(
              builder:
                  (context, state) => Stack(
                    children: [
                      Column(
                        children: [
                          _Header(onBack: widget.onBack, isDark: isDark),
                          Expanded(
                            child: _TrackInfo(state: state, isDark: isDark),
                          ),
                          _PlayerControls(state: state, isDark: isDark),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                      if (state.pendingResumePosition != null &&
                          state.currentAudio != null)
                        Positioned(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          bottom: AppSpacing.xl,
                          child: _ResumePromptCard(
                            trackTitle:
                                state.currentAudio?.displayTitle ??
                                AppLocalizations.of(context).noTrackSelected,
                            position: state.pendingResumePosition!,
                            isDark: isDark,
                            onResume: () {
                              context.read<PlayerBloc>().add(
                                const PlayerResumeFromSavedPosition(),
                              );
                            },
                            onStartOver: () {
                              context.read<PlayerBloc>().add(
                                const PlayerDismissResumePrompt(),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResumePromptIfNeeded(PlayerState state) {
    final promptKey = _resumePromptKey(state);
    if (promptKey == null) {
      _resumePromptTimer?.cancel();
      _resumePromptTimer = null;
      _lastResumePromptKey = null;
      return;
    }
    if (_lastResumePromptKey == promptKey || !mounted) return;
    _lastResumePromptKey = promptKey;
    _resumePromptTimer?.cancel();
    _resumePromptTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_resumePromptKey(context.read<PlayerBloc>().state) == promptKey) {
        context.read<PlayerBloc>().add(const PlayerDismissResumePrompt());
      }
    });
  }

  String? _resumePromptKey(PlayerState state) {
    final pendingResumePosition = state.pendingResumePosition;
    final audioPath = state.currentAudio?.path;
    if (pendingResumePosition == null || audioPath == null) return null;
    return '$audioPath:${pendingResumePosition.inMilliseconds}';
  }
}

class _ResumePromptCard extends StatelessWidget {
  const _ResumePromptCard({
    required this.trackTitle,
    required this.position,
    required this.isDark,
    required this.onResume,
    required this.onStartOver,
  });

  final String trackTitle;
  final Duration position;
  final bool isDark;
  final VoidCallback onResume;
  final VoidCallback onStartOver;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.appPalette;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: palette.subtleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.resumePlaybackPromptTitle,
              style: AppTypography.labelLarge(palette.primaryText),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.resumePlaybackPromptMessage(
                trackTitle,
                TimeParser.formatDuration(position),
              ),
              style: AppTypography.bodySmall(palette.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VercelButton(
                  label: l10n.resumePlaybackPromptStartOver,
                  onPressed: onStartOver,
                  variant: VercelButtonVariant.ghost,
                  size: VercelButtonSize.small,
                ),
                const SizedBox(width: AppSpacing.xs),
                VercelButton(
                  label: l10n.resumePlaybackPromptResume,
                  onPressed: onResume,
                  size: VercelButtonSize.small,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDark, this.onBack});

  final VoidCallback? onBack;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (onBack != null)
            _HeaderButton(
              icon: Icons.keyboard_arrow_down_rounded,
              onTap: onBack!,
              size: 28,
              isDark: isDark,
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInteractive : AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<PlayerBloc, PlayerState>(
                  builder:
                      (context, state) =>
                          AnimatedEqualizer(isPlaying: state.isPlaying),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.nowPlaying,
                  style: AppTypography.labelMedium(
                    isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          BlocBuilder<SleepTimerBloc, SleepTimerState>(
            builder:
                (context, state) => SleepTimerIndicator(
                  remainingTime: state.remainingDuration,
                  isActive: state.isActive,
                  onTap: () => _showSleepTimerDialog(context, state),
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSleepTimerDialog(
    BuildContext context,
    SleepTimerState state,
  ) async {
    final result = await SleepTimerDialog.show(
      context,
      currentDuration: state.remainingDuration,
      isActive: state.isActive,
    );

    if (result != null && context.mounted) {
      if (result.isNegative) {
        context.read<SleepTimerBloc>().add(const SleepTimerCancel());
      } else {
        context.read<SleepTimerBloc>().add(SleepTimerStart(duration: result));
      }
    }
  }
}

class _HeaderButton extends StatefulWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.size = 24,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool isDark;

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color:
              _isHovered
                  ? (widget.isDark ? AppColors.gray800 : AppColors.gray200)
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          color:
              _isHovered
                  ? (widget.isDark ? AppColors.white : AppColors.gray900)
                  : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
          size: widget.size,
        ),
      ),
    ),
  );
}

class _TrackInfo extends StatelessWidget {
  const _TrackInfo({required this.state, required this.isDark});

  final PlayerState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.appPalette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxArtSize = (constraints.maxHeight - 120).clamp(140.0, 280.0);

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: maxArtSize,
                  height: maxArtSize,
                  decoration: BoxDecoration(
                    color: palette.elevatedSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      state.currentAudio?.artworkPath != null &&
                              state.currentAudio!.artworkPath!.isNotEmpty
                          ? Image.file(
                            File(state.currentAudio!.artworkPath!),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, _, _) => Icon(
                                  Icons.music_note_rounded,
                                  color: palette.mutedText,
                                  size: 48,
                                ),
                          )
                          : Icon(
                            Icons.music_note_rounded,
                            color: palette.mutedText,
                            size: 48,
                          ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  state.currentAudio?.displayTitle ?? l10n.noTrackSelected,
                  style: AppTypography.displaySmall(
                    palette.primaryText,
                  ).copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.6),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  state.currentAudio?.artist ?? l10n.unknownArtist,
                  style: AppTypography.bodyMedium(palette.secondaryText),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({required this.state, required this.isDark});

  final PlayerState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar with time jump button
        Row(
          children: [
            Expanded(
              child: ProgressBar(
                position: state.position,
                duration: state.duration ?? Duration.zero,
                onSeek: (position) {
                  context.read<PlayerBloc>().add(PlayerSeekTo(position));
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _TimeJumpButton(
              onTap: () => _showTimeInputDialog(context),
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Playback controls — fixed size, no scale-down on narrow phones
        BlocBuilder<SettingsBloc, SettingsState>(
          builder:
              (
                context,
                settingsState,
              ) => BlocBuilder<PlaylistBloc, PlaylistState>(
                builder:
                    (context, playlistState) => PlaybackControls(
                      isPlaying: state.isPlaying,
                      onPlayPause: () {
                        if (state.isPlaying) {
                          context.read<PlayerBloc>().add(const PlayerPause());
                        } else {
                          context.read<PlayerBloc>().add(const PlayerPlay());
                        }
                      },
                      onPrevious: () {
                        context.read<PlaylistBloc>().add(
                          const PlaylistPlayPrevious(),
                        );
                      },
                      onNext: () {
                        context.read<PlaylistBloc>().add(
                          const PlaylistPlayNext(),
                        );
                      },
                      onSkipBackward: () {
                        context.read<PlayerBloc>().add(
                          const PlayerSkipBackward(),
                        );
                      },
                      onSkipForward: () {
                        context.read<PlayerBloc>().add(
                          const PlayerSkipForward(),
                        );
                      },
                      hasPrevious: playlistState.hasPrevious,
                      hasNext: playlistState.hasNext,
                      skipBackwardSeconds:
                          settingsState.settings.skipBackwardSeconds,
                      skipForwardSeconds:
                          settingsState.settings.skipForwardSeconds,
                      size: PlaybackControlsSize.large,
                    ),
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Volume and speed controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: VolumeSlider(
                volume: state.volume,
                isMuted: state.isMuted,
                onChanged: (volume) {
                  context.read<PlayerBloc>().add(PlayerSetVolume(volume));
                },
                onMuteToggle: () {
                  context.read<PlayerBloc>().add(const PlayerToggleMute());
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _SpeedButton(speed: state.speed, isDark: isDark),
          ],
        ),
      ],
    ),
  );

  Future<void> _showTimeInputDialog(BuildContext context) async {
    final result = await TimeInputDialog.show(
      context,
      duration: state.duration ?? Duration.zero,
      currentPosition: state.position,
    );

    if (result != null && context.mounted) {
      context.read<PlayerBloc>().add(PlayerSeekTo(result));
    }
  }
}

class _TimeJumpButton extends StatefulWidget {
  const _TimeJumpButton({required this.onTap, required this.isDark});

  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_TimeJumpButton> createState() => _TimeJumpButtonState();
}

class _TimeJumpButtonState extends State<_TimeJumpButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Tooltip(
      message: l10n.jumpToTime,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color:
                  _isHovered
                      ? (widget.isDark
                          ? AppColors.darkInteractive
                          : AppColors.gray200)
                      : (widget.isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Icon(
              Icons.timer_outlined,
              color:
                  _isHovered
                      ? (widget.isDark ? AppColors.white : AppColors.gray900)
                      : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedButton extends StatefulWidget {
  const _SpeedButton({required this.speed, required this.isDark});

  final double speed;
  final bool isDark;

  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () => _showSpeedMenu(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              _isHovered
                  ? (widget.isDark ? AppColors.gray800 : AppColors.gray200)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color:
                _isHovered
                    ? (widget.isDark ? AppColors.gray700 : AppColors.gray300)
                    : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed_rounded,
              color:
                  widget.speed != 1.0
                      ? (widget.isDark ? AppColors.white : AppColors.blue)
                      : (widget.isDark ? AppColors.gray500 : AppColors.gray400),
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${widget.speed}x',
              style: TextStyle(
                color:
                    widget.speed != 1.0
                        ? (widget.isDark ? AppColors.white : AppColors.blue)
                        : (widget.isDark
                            ? AppColors.gray400
                            : AppColors.gray600),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _showSpeedMenu(BuildContext context) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.darkElevated : AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder:
          (context) => SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray700 : AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      l10n.playbackSpeed,
                      style: TextStyle(
                        color: isDark ? AppColors.white : AppColors.gray900,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            speeds
                                .map(
                                  (speed) => _SpeedOption(
                                    speed: speed,
                                    isSelected: speed == widget.speed,
                                    isDark: isDark,
                                    onTap: () {
                                      context.read<PlayerBloc>().add(
                                        PlayerSetSpeed(speed),
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
    );
  }
}

class _SpeedOption extends StatefulWidget {
  const _SpeedOption({
    required this.speed,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final double speed;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_SpeedOption> createState() => _SpeedOptionState();
}

class _SpeedOptionState extends State<_SpeedOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          color:
              _isHovered
                  ? (widget.isDark ? AppColors.gray900 : AppColors.gray100)
                  : Colors.transparent,
          child: Row(
            children: [
              Text(
                '${widget.speed}x',
                style: TextStyle(
                  color:
                      widget.isSelected
                          ? (widget.isDark ? AppColors.white : AppColors.blue)
                          : (widget.isDark
                              ? AppColors.gray400
                              : AppColors.gray600),
                  fontSize: 16,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (widget.speed == 1.0) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.isDark ? AppColors.gray800 : AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    l10n.normalSpeed,
                    style: TextStyle(
                      color:
                          widget.isDark ? AppColors.gray500 : AppColors.gray500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (widget.isSelected)
                Icon(
                  Icons.check_rounded,
                  color: widget.isDark ? AppColors.white : AppColors.blue,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
