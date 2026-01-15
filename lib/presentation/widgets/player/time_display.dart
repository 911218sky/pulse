import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/utils/time_parser.dart';

/// Display mode for time
enum TimeDisplayMode { elapsed, remaining, total }

/// A widget to display playback time
class TimeDisplay extends StatelessWidget {
  const TimeDisplay({
    required this.position,
    required this.duration,
    super.key,
    this.mode = TimeDisplayMode.elapsed,
    this.showDuration = true,
    this.fontSize = 14,
    this.onTap,
  });

  final Duration position;
  final Duration duration;
  final TimeDisplayMode mode;
  final bool showDuration;
  final double fontSize;
  final VoidCallback? onTap;

  String get _displayTime {
    switch (mode) {
      case TimeDisplayMode.elapsed:
        return TimeParser.formatDuration(position);
      case TimeDisplayMode.remaining:
        final remaining = duration - position;
        return '-${TimeParser.formatDuration(remaining.isNegative ? Duration.zero : remaining)}';
      case TimeDisplayMode.total:
        return TimeParser.formatDuration(duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeText = Text(
      _displayTime,
      style: TextStyle(
        color: AppColors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    if (!showDuration || mode == TimeDisplayMode.total) {
      return onTap != null
          ? GestureDetector(onTap: onTap, child: timeText)
          : timeText;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        timeText,
        Text(
          ' / ${TimeParser.formatDuration(duration)}',
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: fontSize,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: content)
        : content;
  }
}

/// A compact time display showing elapsed/remaining toggle
class CompactTimeDisplay extends StatefulWidget {
  const CompactTimeDisplay({
    required this.position,
    required this.duration,
    super.key,
    this.fontSize = 12,
  });

  final Duration position;
  final Duration duration;
  final double fontSize;

  @override
  State<CompactTimeDisplay> createState() => _CompactTimeDisplayState();
}

class _CompactTimeDisplayState extends State<CompactTimeDisplay> {
  bool _showRemaining = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _showRemaining = !_showRemaining),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: TimeDisplay(
        position: widget.position,
        duration: widget.duration,
        mode:
            _showRemaining
                ? TimeDisplayMode.remaining
                : TimeDisplayMode.elapsed,
        showDuration: false,
        fontSize: widget.fontSize,
      ),
    ),
  );
}
