import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';

/// Result from sleep timer dialog
class SleepTimerResult {
  const SleepTimerResult({
    required this.duration,
    required this.fadeOutEnabled,
    required this.fadeOutSeconds,
  });

  final Duration duration;
  final bool fadeOutEnabled;
  final int fadeOutSeconds;
}

/// Preset durations for sleep timer
enum SleepTimerPreset {
  minutes15(Duration(minutes: 15), '15'),
  minutes30(Duration(minutes: 30), '30'),
  minutes45(Duration(minutes: 45), '45'),
  hour1(Duration(hours: 1), '1'),
  hour2(Duration(hours: 2), '2'),
  endOfTrack(Duration.zero, '🎵');

  const SleepTimerPreset(this.duration, this.value);

  final Duration duration;
  final String value;
}

/// A dialog for setting the sleep timer
class SleepTimerDialog extends StatefulWidget {
  const SleepTimerDialog({
    super.key,
    this.currentDuration,
    this.isActive = false,
  });

  final Duration? currentDuration;
  final bool isActive;

  /// Show the dialog and return the selected duration
  /// Returns null if cancelled, Duration.zero for end of track
  static Future<Duration?> show(
    BuildContext context, {
    Duration? currentDuration,
    bool isActive = false,
  }) => showDialog<Duration>(
    context: context,
    builder:
        (context) => SleepTimerDialog(
          currentDuration: currentDuration,
          isActive: isActive,
        ),
  );

  @override
  State<SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<SleepTimerDialog> {
  SleepTimerPreset? _selectedPreset;
  bool _isCustom = false;
  int _customHours = 0;
  int _customMinutes = 30;
  int _customSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.currentDuration != null) {
      // Try to match with a preset
      for (final preset in SleepTimerPreset.values) {
        if (preset.duration == widget.currentDuration) {
          _selectedPreset = preset;
          return;
        }
      }
      // Custom duration
      _isCustom = true;
      _customHours = widget.currentDuration!.inHours;
      _customMinutes = widget.currentDuration!.inMinutes % 60;
      _customSeconds = widget.currentDuration!.inSeconds % 60;
    }
  }

  void _selectPreset(SleepTimerPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _isCustom = false;
    });
  }

  void _selectCustom() {
    setState(() {
      _selectedPreset = null;
      _isCustom = true;
    });
  }

  Duration get _customDuration => Duration(
    hours: _customHours,
    minutes: _customMinutes,
    seconds: _customSeconds,
  );

  void _submit() {
    if (_isCustom) {
      Navigator.of(context).pop(_customDuration);
    } else if (_selectedPreset != null) {
      Navigator.of(context).pop(_selectedPreset!.duration);
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _stop() {
    Navigator.of(context).pop(const Duration(seconds: -1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: isDark ? AppColors.gray800 : AppColors.gray200),
      ),
      child: Container(
        width: 380,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isDark, l10n),
              const SizedBox(height: AppSpacing.xl),
              _buildPresetGrid(isDark, l10n),
              const SizedBox(height: AppSpacing.md),
              _buildCustomOption(isDark, l10n),
              if (_isCustom) ...[
                const SizedBox(height: AppSpacing.md),
                _buildCustomPicker(isDark, l10n),
              ],
              const SizedBox(height: AppSpacing.xl),
              _buildActions(isDark, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l10n) => Column(
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [AppColors.gray800, AppColors.gray900]
                    : [
                      AppColors.accentLight.withValues(alpha: 0.2),
                      AppColors.accent.withValues(alpha: 0.3),
                    ],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.bedtime_rounded,
          color: isDark ? AppColors.white : AppColors.accent,
          size: 28,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        l10n.sleepTimerTitle,
        style: TextStyle(
          color: isDark ? AppColors.white : AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        widget.isActive ? l10n.sleepTimerActive : l10n.sleepTimerSetTime,
        style: TextStyle(
          color:
              widget.isActive
                  ? (isDark ? AppColors.success : AppColors.accent)
                  : (isDark ? AppColors.gray500 : AppColors.gray600),
          fontSize: 13,
        ),
      ),
    ],
  );

  Widget _buildPresetGrid(bool isDark, AppLocalizations l10n) => GridView.count(
    shrinkWrap: true,
    crossAxisCount: 3,
    mainAxisSpacing: AppSpacing.md,
    crossAxisSpacing: AppSpacing.md,
    childAspectRatio: 1.2,
    physics: const NeverScrollableScrollPhysics(),
    children:
        SleepTimerPreset.values.map((preset) {
          final isSelected = _selectedPreset == preset && !_isCustom;
          final unit = _getPresetUnit(preset, l10n);
          return _PresetCard(
            value: preset.value,
            unit: unit,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => _selectPreset(preset),
          );
        }).toList(),
  );

  String _getPresetUnit(SleepTimerPreset preset, AppLocalizations l10n) {
    switch (preset) {
      case SleepTimerPreset.minutes15:
      case SleepTimerPreset.minutes30:
      case SleepTimerPreset.minutes45:
        return l10n.minutes;
      case SleepTimerPreset.hour1:
      case SleepTimerPreset.hour2:
        return l10n.hours;
      case SleepTimerPreset.endOfTrack:
        return l10n.endOfTrack;
    }
  }

  Widget _buildCustomOption(bool isDark, AppLocalizations l10n) =>
      _CustomOptionCard(
        isSelected: _isCustom,
        isDark: isDark,
        onTap: _selectCustom,
        duration: _isCustom ? _customDuration : null,
        l10n: l10n,
      );

  Widget _buildCustomPicker(bool isDark, AppLocalizations l10n) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: isDark ? AppColors.gray900 : AppColors.gray100,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: isDark ? AppColors.gray800 : AppColors.gray200),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildWheelPicker(
            value: _customHours,
            maxValue: 23,
            label: l10n.hour,
            isDark: isDark,
            onChanged: (v) => setState(() => _customHours = v),
          ),
        ),
        Text(
          ':',
          style: TextStyle(
            color: isDark ? AppColors.gray500 : AppColors.gray400,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
        Expanded(
          child: _buildWheelPicker(
            value: _customMinutes,
            maxValue: 59,
            label: l10n.minute,
            isDark: isDark,
            onChanged: (v) => setState(() => _customMinutes = v),
          ),
        ),
        Text(
          ':',
          style: TextStyle(
            color: isDark ? AppColors.gray500 : AppColors.gray400,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
        Expanded(
          child: _buildWheelPicker(
            value: _customSeconds,
            maxValue: 59,
            label: l10n.second,
            isDark: isDark,
            onChanged: (v) => setState(() => _customSeconds = v),
          ),
        ),
      ],
    ),
  );

  Widget _buildWheelPicker({
    required int value,
    required int maxValue,
    required String label,
    required bool isDark,
    required ValueChanged<int> onChanged,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 100,
        child: ListWheelScrollView.useDelegate(
          itemExtent: 36,
          perspective: 0.005,
          diameterRatio: 1.2,
          physics: const FixedExtentScrollPhysics(),
          controller: FixedExtentScrollController(initialItem: value),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: maxValue + 1,
            builder: (context, index) {
              final isSelected = index == value;
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color:
                        isSelected
                            ? (isDark ? AppColors.white : AppColors.accent)
                            : (isDark ? AppColors.gray600 : AppColors.gray400),
                    fontSize: isSelected ? 22 : 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      Text(
        label,
        style: TextStyle(
          color: isDark ? AppColors.gray500 : AppColors.gray600,
          fontSize: 11,
        ),
      ),
    ],
  );

  Widget _buildActions(bool isDark, AppLocalizations l10n) => Row(
    children: [
      if (widget.isActive) ...[
        Expanded(
          child: VercelButton(
            label: l10n.stopTimer,
            icon: Icons.stop_rounded,
            variant: VercelButtonVariant.danger,
            fullWidth: true,
            isDark: isDark,
            onPressed: _stop,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      Expanded(
        child: VercelButton(
          label: l10n.cancel,
          variant: VercelButtonVariant.secondary,
          fullWidth: true,
          isDark: isDark,
          onPressed: _cancel,
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: VercelButton(
          label: widget.isActive ? l10n.update : l10n.start,
          icon:
              widget.isActive
                  ? Icons.refresh_rounded
                  : Icons.play_arrow_rounded,
          fullWidth: true,
          isDark: isDark,
          isDisabled: !_isCustom && _selectedPreset == null,
          onPressed: _submit,
        ),
      ),
    ],
  );
}

class _PresetCard extends StatefulWidget {
  const _PresetCard({
    required this.value,
    required this.unit,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String value;
  final String unit;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_PresetCard> createState() => _PresetCardState();
}

class _PresetCardState extends State<_PresetCard> {
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
        decoration: BoxDecoration(
          color:
              widget.isSelected
                  ? (widget.isDark ? AppColors.white : AppColors.accent)
                  : _isHovered
                  ? (widget.isDark ? AppColors.gray800 : AppColors.gray100)
                  : (widget.isDark ? AppColors.gray900 : AppColors.gray50),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color:
                widget.isSelected
                    ? (widget.isDark ? AppColors.white : AppColors.accent)
                    : _isHovered
                    ? (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                    : (widget.isDark ? AppColors.gray800 : AppColors.gray200),
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.value,
              style: TextStyle(
                color:
                    widget.isSelected
                        ? (widget.isDark ? AppColors.black : AppColors.white)
                        : (widget.isDark ? AppColors.white : AppColors.black),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.unit,
              style: TextStyle(
                color:
                    widget.isSelected
                        ? (widget.isDark
                            ? AppColors.gray600
                            : AppColors.white.withValues(alpha: 0.8))
                        : (widget.isDark
                            ? AppColors.gray500
                            : AppColors.gray600),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CustomOptionCard extends StatefulWidget {
  const _CustomOptionCard({
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    required this.l10n,
    this.duration,
  });

  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final Duration? duration;
  final AppLocalizations l10n;

  @override
  State<_CustomOptionCard> createState() => _CustomOptionCardState();
}

class _CustomOptionCardState extends State<_CustomOptionCard> {
  bool _isHovered = false;

  String get _displayText {
    if (widget.duration == null) return widget.l10n.customTime;
    final hours = widget.duration!.inHours;
    final minutes = widget.duration!.inMinutes % 60;
    final seconds = widget.duration!.inSeconds % 60;
    final parts = <String>[];
    if (hours > 0) parts.add('$hours ${widget.l10n.hours}');
    if (minutes > 0) parts.add('$minutes ${widget.l10n.minutes}');
    if (seconds > 0) parts.add('$seconds ${widget.l10n.second}');
    return parts.isEmpty ? '0 ${widget.l10n.second}' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color:
              widget.isSelected
                  ? (widget.isDark
                      ? AppColors.white.withValues(alpha: 0.1)
                      : AppColors.accent.withValues(alpha: 0.1))
                  : _isHovered
                  ? (widget.isDark ? AppColors.gray800 : AppColors.gray100)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color:
                widget.isSelected
                    ? (widget.isDark ? AppColors.white : AppColors.accent)
                    : _isHovered
                    ? (widget.isDark ? AppColors.gray600 : AppColors.gray300)
                    : (widget.isDark ? AppColors.gray800 : AppColors.gray200),
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              color:
                  widget.isSelected
                      ? (widget.isDark ? AppColors.white : AppColors.accent)
                      : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _displayText,
              style: TextStyle(
                color:
                    widget.isSelected
                        ? (widget.isDark ? AppColors.white : AppColors.accent)
                        : (widget.isDark
                            ? AppColors.gray400
                            : AppColors.gray600),
                fontSize: 14,
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
