import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/utils/time_parser.dart';

/// A Vercel-style progress bar for audio playback
/// Optimized for large files (100+ hours) with smooth dragging
/// Features:
/// - Click anywhere to seek
/// - Drag to seek with time preview bubble
/// - Smooth performance for large files
class ProgressBar extends StatefulWidget {
  const ProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    super.key,
    this.bufferedPosition = Duration.zero,
    this.showTimeLabels = true,
    this.height = 6,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  child: Container(
                    height: 64,
                    color: Colors.transparent,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Track
                        _buildTrack(constraints, isDark),
                        // Time preview bubble when dragging
                        if (_isDragging)
                          _buildPreviewBubble(constraints, isDark),
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

  Widget _buildTrack(BoxConstraints constraints, bool isDark) {
    final clampedProgress = _progress.clamp(0.0, 1.0);
    final clampedBuffered = _bufferedProgress.clamp(0.0, 1.0);
    // Larger track height for easier touch
    final trackHeight = _isHovered || _isDragging ? 12.0 : 8.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: trackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background track
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray800 : AppColors.gray200,
              borderRadius: BorderRadius.circular(trackHeight / 2),
            ),
          ),
          // Buffered progress
          FractionallySizedBox(
            widthFactor: clampedBuffered,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray600 : AppColors.gray300,
                borderRadius: BorderRadius.circular(trackHeight / 2),
              ),
            ),
          ),
          // Current progress
          FractionallySizedBox(
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.white : AppColors.blue,
                borderRadius: BorderRadius.circular(trackHeight / 2),
              ),
            ),
          ),
          // Thumb - larger for easier touch
          if (_isHovered || _isDragging)
            Positioned(
              left: (clampedProgress * constraints.maxWidth) - 10,
              top: (trackHeight - 20) / 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white : AppColors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewBubble(BoxConstraints constraints, bool isDark) {
    final bubbleX = (_dragValue * constraints.maxWidth).clamp(
      30.0,
      constraints.maxWidth - 30,
    );

    return Positioned(
      left: bubbleX - 50,
      top: -40,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray900 : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isDark ? AppColors.gray700 : AppColors.gray200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          TimeParser.formatDuration(_previewPosition),
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.gray900,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Time labels widget
class _TimeLabels extends StatelessWidget {
  const _TimeLabels({required this.position, required this.duration});

  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          TimeParser.formatDuration(position),
          style: TextStyle(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            fontSize: 12,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          TimeParser.formatDuration(duration),
          style: TextStyle(
            color: isDark ? AppColors.gray400 : AppColors.gray600,
            fontSize: 12,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
