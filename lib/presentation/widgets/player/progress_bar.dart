import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';
import 'package:pulse/core/utils/time_parser.dart';

/// A Vercel-style progress bar for audio playback.
/// Optimized for large files with smooth dragging and a generous hit target.
class ProgressBar extends StatefulWidget {
  const ProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    super.key,
    this.bufferedPosition = Duration.zero,
    this.showTimeLabels = true,
    this.height = AppSpacing.progressBarHeightExpanded,
  });

  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final ValueChanged<Duration> onSeek;
  final bool showTimeLabels;
  final double height;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0;
  bool _isHovered = false;

  double get _progress {
    if (widget.duration.inMilliseconds == 0) return 0;
    if (_isDragging) return _dragValue;
    return widget.position.inMilliseconds / widget.duration.inMilliseconds;
  }

  double get _bufferedProgress {
    if (widget.duration.inMilliseconds == 0) return 0;
    return widget.bufferedPosition.inMilliseconds /
        widget.duration.inMilliseconds;
  }

  Duration get _displayPosition {
    if (_isDragging) {
      return Duration(
        milliseconds: (_dragValue * widget.duration.inMilliseconds).round(),
      );
    }
    return widget.position;
  }

  Duration get _previewPosition => Duration(
    milliseconds: (_dragValue * widget.duration.inMilliseconds).round(),
  );

  void _handleInteraction(double localX, double maxWidth) {
    final newValue = (localX / maxWidth).clamp(0.0, 1.0);
    setState(() {
      _dragValue = newValue;
      _isDragging = true;
    });
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    _handleInteraction(details.localPosition.dx, constraints.maxWidth);
  }

  void _onTapUp(TapUpDetails details, BoxConstraints constraints) {
    final tapValue = (details.localPosition.dx / constraints.maxWidth).clamp(
      0.0,
      1.0,
    );
    final seekPosition = Duration(
      milliseconds: (tapValue * widget.duration.inMilliseconds).round(),
    );
    setState(() => _isDragging = false);
    widget.onSeek(seekPosition);
  }

  void _onDragStart(DragStartDetails details, BoxConstraints constraints) {
    _handleInteraction(details.localPosition.dx, constraints.maxWidth);
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (!_isDragging) return;
    final newValue = (details.localPosition.dx / constraints.maxWidth).clamp(
      0.0,
      1.0,
    );
    setState(() => _dragValue = newValue);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final seekPosition = Duration(
      milliseconds: (_dragValue * widget.duration.inMilliseconds).round(),
    );

    setState(() => _isDragging = false);
    widget.onSeek(seekPosition);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isDark = context.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder:
              (context, constraints) => MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => _onTapDown(details, constraints),
                  onTapUp: (details) => _onTapUp(details, constraints),
                  onHorizontalDragStart:
                      (details) => _onDragStart(details, constraints),
                  onHorizontalDragUpdate:
                      (details) => _onDragUpdate(details, constraints),
                  onHorizontalDragEnd: _onDragEnd,
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        _buildTrack(constraints, isDark, palette),
                        if (_isDragging)
                          _buildPreviewBubble(constraints, palette),
                      ],
                    ),
                  ),
                ),
              ),
        ),
        if (widget.showTimeLabels)
          _TimeLabels(position: _displayPosition, duration: widget.duration),
      ],
    );
  }

  Widget _buildTrack(
    BoxConstraints constraints,
    bool isDark,
    AppThemePalette palette,
  ) {
    final clampedProgress = _progress.clamp(0.0, 1.0);
    final clampedBuffered = _bufferedProgress.clamp(0.0, 1.0);
    final trackHeight =
        _isHovered || _isDragging
            ? AppSpacing.progressThumbSize
            : widget.height;

    return AnimatedContainer(
      duration: AppDurations.fast,
      height: trackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray800 : AppColors.gray200,
              borderRadius: BorderRadius.circular(trackHeight / 2),
            ),
          ),
          FractionallySizedBox(
            widthFactor: clampedBuffered,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray600 : AppColors.gray300,
                borderRadius: BorderRadius.circular(trackHeight / 2),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.white : AppColors.accent,
                borderRadius: BorderRadius.circular(trackHeight / 2),
              ),
            ),
          ),
          if (_isHovered || _isDragging)
            Positioned(
              left:
                  (clampedProgress * constraints.maxWidth) -
                  (AppSpacing.progressThumbSize / 2),
              top: (trackHeight - AppSpacing.progressThumbSize) / 2,
              child: Container(
                width: AppSpacing.progressThumbSize,
                height: AppSpacing.progressThumbSize,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white : AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.subtleBorder),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewBubble(
    BoxConstraints constraints,
    AppThemePalette palette,
  ) {
    final bubbleX = (_dragValue * constraints.maxWidth).clamp(
      30.0,
      constraints.maxWidth - 30,
    );

    return Positioned(
      left: bubbleX - 50,
      top: -36,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: palette.subtleBorder),
        ),
        child: Text(
          TimeParser.formatDuration(_previewPosition),
          style: AppTypography.timeDisplay(palette.primaryText),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _TimeLabels extends StatelessWidget {
  const _TimeLabels({required this.position, required this.duration});

  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          TimeParser.formatDuration(position),
          style: AppTypography.timeDisplay(palette.secondaryText),
        ),
        Text(
          TimeParser.formatDuration(duration),
          style: AppTypography.timeDisplay(palette.secondaryText),
        ),
      ],
    );
  }
}
