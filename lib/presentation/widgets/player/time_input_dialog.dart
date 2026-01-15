import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/utils/time_parser.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';

/// A dialog for inputting time to jump to using scroll wheel pickers
class TimeInputDialog extends StatefulWidget {
  const TimeInputDialog({
    required this.duration,
    super.key,
    this.currentPosition,
  });

  final Duration duration;
  final Duration? currentPosition;

  /// Show the dialog and return the selected duration
  static Future<Duration?> show(
    BuildContext context, {
    required Duration duration,
    Duration? currentPosition,
  }) => showDialog<Duration>(
    context: context,
    builder:
        (context) => TimeInputDialog(
          duration: duration,
          currentPosition: currentPosition,
        ),
  );

  @override
  State<TimeInputDialog> createState() => _TimeInputDialogState();
}

class _TimeInputDialogState extends State<TimeInputDialog> {
  late int _hours;
  late int _minutes;
  late int _seconds;
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

  int get _maxHours => widget.duration.inHours;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentPosition ?? Duration.zero;
    _hours = initial.inHours;
    _minutes = initial.inMinutes.remainder(60);
    _seconds = initial.inSeconds.remainder(60);

    _hoursController = FixedExtentScrollController(initialItem: _hours);
    _minutesController = FixedExtentScrollController(initialItem: _minutes);
    _secondsController = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  Duration get _selectedDuration =>
      Duration(hours: _hours, minutes: _minutes, seconds: _seconds);

  bool get _isValid => _selectedDuration <= widget.duration;

  void _submit() {
    if (!_isValid) return;
    Navigator.of(context).pop(_selectedDuration);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: isDark ? AppColors.gray700 : AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.jumpToTimeTitle,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.gray900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.totalDuration(TimeParser.formatDuration(widget.duration)),
              style: TextStyle(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Scroll wheel pickers
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Hours picker
                  Expanded(
                    child: _WheelPicker(
                      label: l10n.hourLabel,
                      itemCount: _maxHours + 1,
                      controller: _hoursController,
                      onChanged: (value) => setState(() => _hours = value),
                      isDark: isDark,
                    ),
                  ),
                  _Separator(isDark: isDark),
                  // Minutes picker
                  Expanded(
                    child: _WheelPicker(
                      label: l10n.minuteLabel,
                      itemCount: 60,
                      controller: _minutesController,
                      onChanged: (value) => setState(() => _minutes = value),
                      isDark: isDark,
                    ),
                  ),
                  _Separator(isDark: isDark),
                  // Seconds picker
                  Expanded(
                    child: _WheelPicker(
                      label: l10n.secondLabel,
                      itemCount: 60,
                      controller: _secondsController,
                      onChanged: (value) => setState(() => _seconds = value),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Selected time preview
            Center(
              child: Text(
                TimeParser.formatDuration(_selectedDuration),
                style: TextStyle(
                  color:
                      _isValid
                          ? (isDark ? AppColors.white : AppColors.gray900)
                          : AppColors.error,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (!_isValid) ...[
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  l10n.timeExceedsDuration,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VercelButton(
                  label: l10n.cancel,
                  variant: VercelButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: AppSpacing.md),
                VercelButton(
                  label: l10n.jump,
                  isDisabled: !_isValid,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPicker extends StatelessWidget {
  const _WheelPicker({
    required this.label,
    required this.itemCount,
    required this.controller,
    required this.onChanged,
    required this.isDark,
  });

  final String label;
  final int itemCount;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: TextStyle(
          color: isDark ? AppColors.gray400 : AppColors.gray600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Expanded(
        child: Stack(
          children: [
            // Selection highlight
            Center(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray800 : AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
            // Wheel
            ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 44,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: itemCount,
                builder:
                    (context, index) => Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColors.gray900,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Separator extends StatelessWidget {
  const _Separator({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 30),
    child: Text(
      ':',
      style: TextStyle(
        color: isDark ? AppColors.gray400 : AppColors.gray500,
        fontSize: 28,
        fontWeight: FontWeight.w300,
      ),
    ),
  );
}
