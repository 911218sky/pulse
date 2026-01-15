import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/utils/time_parser.dart';

/// An indicator showing the sleep timer status
class SleepTimerIndicator extends StatefulWidget {
  const SleepTimerIndicator({
    required this.remainingTime,
    super.key,
    this.isActive = false,
    this.onTap,
    this.compact = false,
  });

  final Duration remainingTime;
  final bool isActive;
  final VoidCallback? onTap;
  final bool compact;

  @override
  State<SleepTimerIndicator> createState() => _SleepTimerIndicatorState();
}

class _SleepTimerIndicatorState extends State<SleepTimerIndicator> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!widget.isActive) {
      return _InactiveIndicator(onTap: widget.onTap, compact: widget.compact);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? AppSpacing.sm : AppSpacing.md,
            vertical: widget.compact ? AppSpacing.xs : AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? (isDark ? AppColors.gray700 : AppColors.gray200)
                    : (isDark ? AppColors.gray800 : AppColors.gray100),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.gray700 : AppColors.gray200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bedtime_rounded,
                color: isDark ? AppColors.white : AppColors.blue,
                size: widget.compact ? 14 : 16,
              ),
              SizedBox(width: widget.compact ? AppSpacing.xs : AppSpacing.sm),
              Text(
                _formatRemainingTime(),
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColors.gray900,
                  fontSize: widget.compact ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRemainingTime() {
    if (widget.remainingTime.inSeconds <= 0) {
      return '0:00';
    }
    return TimeParser.formatDuration(widget.remainingTime);
  }
}

class _InactiveIndicator extends StatefulWidget {
  const _InactiveIndicator({this.onTap, this.compact = false});

  final VoidCallback? onTap;
  final bool compact;

  @override
  State<_InactiveIndicator> createState() => _InactiveIndicatorState();
}

class _InactiveIndicatorState extends State<_InactiveIndicator> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: EdgeInsets.all(
            widget.compact ? AppSpacing.xs : AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? (isDark ? AppColors.gray800 : AppColors.gray200)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            Icons.bedtime_outlined,
            color: isDark ? AppColors.gray500 : AppColors.gray400,
            size: widget.compact ? 18 : 20,
          ),
        ),
      ),
    );
  }
}

/// A larger sleep timer display for the player screen
class SleepTimerBadge extends StatelessWidget {
  const SleepTimerBadge({
    required this.remainingTime,
    super.key,
    this.isActive = false,
    this.onTap,
  });

  final Duration remainingTime;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray900 : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isDark ? AppColors.gray700 : AppColors.gray200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bedtime_rounded,
              color: isDark ? AppColors.white : AppColors.blue,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.sleepTimerDisplay(TimeParser.formatDuration(remainingTime)),
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.gray900,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
