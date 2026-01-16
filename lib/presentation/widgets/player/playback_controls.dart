import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';

/// A Vercel-style playback controls widget
class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    required this.isPlaying,
    required this.onPlayPause,
    super.key,
    this.onPrevious,
    this.onNext,
    this.onSkipBackward,
    this.onSkipForward,
    this.hasPrevious = true,
    this.hasNext = true,
    this.skipBackwardSeconds = 10,
    this.skipForwardSeconds = 30,
    this.showSkipButtons = true,
    this.size = PlaybackControlsSize.medium,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSkipBackward;
  final VoidCallback? onSkipForward;
  final bool hasPrevious;
  final bool hasNext;
  final int skipBackwardSeconds;
  final int skipForwardSeconds;
  final bool showSkipButtons;
  final PlaybackControlsSize size;

  double get _mainButtonSize => switch (size) {
    PlaybackControlsSize.small => 40,
    PlaybackControlsSize.medium => 56,
    PlaybackControlsSize.large => 72,
  };

  double get _secondaryButtonSize => switch (size) {
    PlaybackControlsSize.small => 32,
    PlaybackControlsSize.medium => 40,
    PlaybackControlsSize.large => 48,
  };

  double get _mainIconSize => switch (size) {
    PlaybackControlsSize.small => 20,
    PlaybackControlsSize.medium => 28,
    PlaybackControlsSize.large => 36,
  };

  double get _secondaryIconSize => switch (size) {
    PlaybackControlsSize.small => 18,
    PlaybackControlsSize.medium => 22,
    PlaybackControlsSize.large => 26,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward button
        if (showSkipButtons)
          _SkipButton(
            seconds: skipBackwardSeconds,
            isForward: false,
            onTap: onSkipBackward,
            size: _secondaryButtonSize,
            isDark: isDark,
          ),
        if (showSkipButtons) const SizedBox(width: AppSpacing.md),

        // Previous button
        _ControlButton(
          icon: Icons.skip_previous_rounded,
          onTap: hasPrevious ? onPrevious : null,
          size: _secondaryButtonSize,
          iconSize: _secondaryIconSize,
          isDark: isDark,
        ),
        const SizedBox(width: AppSpacing.md),

        // Play/Pause button
        _PlayPauseButton(
          isPlaying: isPlaying,
          onTap: onPlayPause,
          size: _mainButtonSize,
          iconSize: _mainIconSize,
          isDark: isDark,
        ),
        const SizedBox(width: AppSpacing.md),

        // Next button
        _ControlButton(
          icon: Icons.skip_next_rounded,
          onTap: hasNext ? onNext : null,
          size: _secondaryButtonSize,
          iconSize: _secondaryIconSize,
          isDark: isDark,
        ),

        // Skip forward button
        if (showSkipButtons) const SizedBox(width: AppSpacing.md),
        if (showSkipButtons)
          _SkipButton(
            seconds: skipForwardSeconds,
            isForward: true,
            onTap: onSkipForward,
            size: _secondaryButtonSize,
            isDark: isDark,
          ),
      ],
    );
  }
}

/// Size variants for playback controls
enum PlaybackControlsSize { small, medium, large }

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.onTap,
    required this.size,
    required this.iconSize,
    required this.isDark,
  });

  final bool isPlaying;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final bool isDark;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? (widget.isDark
                      ? AppColors.gray200
                      : AppColors.blue.withValues(alpha: 0.8))
                  : _isHovered
                  ? (widget.isDark
                      ? AppColors.gray100
                      : AppColors.blue.withValues(alpha: 0.9))
                  : (widget.isDark ? AppColors.white : AppColors.blue),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: widget.isDark ? AppColors.black : AppColors.white,
          size: widget.iconSize,
        ),
      ),
    ),
  );
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final bool isDark;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isHovered = false;

  bool get _isEnabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color:
              _isHovered && _isEnabled
                  ? (widget.isDark ? AppColors.gray800 : AppColors.gray200)
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          color:
              _isEnabled
                  ? (widget.isDark ? AppColors.white : AppColors.gray800)
                  : (widget.isDark ? AppColors.gray600 : AppColors.gray400),
          size: widget.iconSize,
        ),
      ),
    ),
  );
}

class _SkipButton extends StatefulWidget {
  const _SkipButton({
    required this.seconds,
    required this.isForward,
    required this.size,
    required this.isDark,
    this.onTap,
  });

  final int seconds;
  final bool isForward;
  final VoidCallback? onTap;
  final double size;
  final bool isDark;

  @override
  State<_SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<_SkipButton> {
  bool _isHovered = false;

  bool get _isEnabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final color =
        _isEnabled
            ? (widget.isDark ? AppColors.white : AppColors.gray800)
            : (widget.isDark ? AppColors.gray600 : AppColors.gray400);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color:
                _isHovered && _isEnabled
                    ? (widget.isDark ? AppColors.gray800 : AppColors.gray200)
                    : Colors.transparent,
            shape: BoxShape.circle,
          ),
          // Always use double arrow design with seconds below
          child: _CustomSkipIcon(
            seconds: widget.seconds,
            isForward: widget.isForward,
            color: color,
            size: widget.size * 0.7,
          ),
        ),
      ),
    );
  }
}

/// Custom skip icon for non-standard seconds values
/// Uses double arrow design with seconds below (like fast_rewind/fast_forward)
class _CustomSkipIcon extends StatelessWidget {
  const _CustomSkipIcon({
    required this.seconds,
    required this.isForward,
    required this.color,
    required this.size,
  });

  final int seconds;
  final bool isForward;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Double arrow icon
        Icon(
          isForward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
          color: color,
          size: size * 0.55,
        ),
        // Seconds text below
        Text(
          '${seconds}s',
          style: TextStyle(
            color: color,
            fontSize: size * 0.3,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    ),
  );
}
