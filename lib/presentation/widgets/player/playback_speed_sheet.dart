import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/utils/playback_speed_utils.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';

/// Bottom sheet for choosing a custom playback speed with slider + presets.
class PlaybackSpeedSheet extends StatefulWidget {
  const PlaybackSpeedSheet({required this.initialSpeed, super.key});

  final double initialSpeed;

  /// Shows the custom speed sheet and applies changes via [PlayerBloc].
  static Future<void> show(BuildContext context, {required double speed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.darkElevated : AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder:
          (sheetContext) => BlocProvider.value(
            value: context.read<PlayerBloc>(),
            child: PlaybackSpeedSheet(initialSpeed: speed),
          ),
    );
  }

  @override
  State<PlaybackSpeedSheet> createState() => _PlaybackSpeedSheetState();
}

class _PlaybackSpeedSheetState extends State<PlaybackSpeedSheet> {
  late double _speed;

  @override
  void initState() {
    super.initState();
    _speed = PlaybackSpeedUtils.quantize(widget.initialSpeed);
  }

  void _apply(double value) {
    final quantized = PlaybackSpeedUtils.quantize(value);
    if (PlaybackSpeedUtils.nearlyEquals(quantized, _speed)) {
      return;
    }
    setState(() => _speed = quantized);
    context.read<PlayerBloc>().add(PlayerSetSpeed(quantized));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final labelColor = isDark ? AppColors.white : AppColors.gray900;
    final mutedColor = isDark ? AppColors.gray400 : AppColors.gray600;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                l10n.playbackSpeed,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  _StepButton(
                    icon: Icons.remove_rounded,
                    isDark: isDark,
                    enabled: !PlaybackSpeedUtils.isMinSpeed(_speed),
                    onTap: () => _apply(PlaybackSpeedUtils.decrease(_speed)),
                  ),
                  Expanded(
                    child: Text(
                      PlaybackSpeedUtils.format(_speed),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add_rounded,
                    isDark: isDark,
                    enabled: !PlaybackSpeedUtils.isMaxSpeed(_speed),
                    onTap: () => _apply(PlaybackSpeedUtils.increase(_speed)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: isDark ? AppColors.white : AppColors.accent,
                  inactiveTrackColor:
                      isDark ? AppColors.gray700 : AppColors.gray300,
                  thumbColor: isDark ? AppColors.white : AppColors.accent,
                  overlayColor: (isDark ? AppColors.white : AppColors.accent)
                      .withValues(alpha: 0.1),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _speed,
                  min: PlaybackSpeedUtils.minSpeed,
                  max: PlaybackSpeedUtils.maxSpeed,
                  divisions: PlaybackSpeedUtils.sliderDivisions,
                  label: PlaybackSpeedUtils.format(_speed),
                  onChanged: _apply,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(
                  l10n.speedPresets,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final preset in PlaybackSpeedUtils.presets)
                    _PresetChip(
                      speed: preset,
                      isSelected: PlaybackSpeedUtils.nearlyEquals(
                        preset,
                        _speed,
                      ),
                      isDark: isDark,
                      normalLabel: l10n.normalSpeed,
                      onTap: () => _apply(preset),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.isDark,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg =
        enabled
            ? (isDark ? AppColors.white : AppColors.gray900)
            : (isDark ? AppColors.gray700 : AppColors.gray300);
    final bg = isDark ? AppColors.gray800 : AppColors.gray100;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: fg, size: 22),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.speed,
    required this.isSelected,
    required this.isDark,
    required this.normalLabel,
    required this.onTap,
  });

  final double speed;
  final bool isSelected;
  final bool isDark;
  final String normalLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark ? AppColors.white : AppColors.accent;
    final selectedFg = isDark ? AppColors.black : AppColors.white;
    final idleBg = isDark ? AppColors.gray800 : AppColors.gray100;
    final idleFg = isDark ? AppColors.gray300 : AppColors.gray700;
    final isNormal = PlaybackSpeedUtils.isNormalSpeed(speed);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : idleBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            isNormal
                ? '${PlaybackSpeedUtils.format(speed)} · $normalLabel'
                : PlaybackSpeedUtils.format(speed),
            style: TextStyle(
              color: isSelected ? selectedFg : idleFg,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
