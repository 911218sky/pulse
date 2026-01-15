import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_event.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.onBack,
    this.onSleepTimerPressed,
    this.onFolderScanPressed,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSleepTimerPressed;
  final VoidCallback? onFolderScanPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: onBack, isDark: isDark),
            Expanded(
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state.status == SettingsStatus.loading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          isDark ? AppColors.white : AppColors.accent,
                        ),
                      ),
                    );
                  }

                  return _SettingsContent(
                    state: state,
                    l10n: l10n,
                    isDark: isDark,
                    onSleepTimerPressed: onSleepTimerPressed,
                    onFolderScanPressed: onFolderScanPressed,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.state,
    required this.l10n,
    required this.isDark,
    this.onSleepTimerPressed,
    this.onFolderScanPressed,
  });

  final SettingsState state;
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback? onSleepTimerPressed;
  final VoidCallback? onFolderScanPressed;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    children: [
      _SectionHeader(title: l10n.appearance, isDark: isDark),
      _SwitchTile(
        title: l10n.darkMode,
        subtitle: l10n.darkModeDesc,
        value: state.settings.darkMode,
        isDark: isDark,
        onChanged: (value) {
          context.read<SettingsBloc>().add(
            SettingsUpdateDarkMode(enabled: value),
          );
        },
      ),
      _LanguageTile(
        title: l10n.language,
        subtitle: l10n.languageDesc,
        currentLocale: state.settings.locale,
        isDark: isDark,
        onChanged: (locale) {
          context.read<SettingsBloc>().add(SettingsUpdateLocale(locale));
        },
      ),
      const SizedBox(height: AppSpacing.xl),
      _SectionHeader(title: l10n.playback, isDark: isDark),
      _SliderTile(
        title: l10n.defaultVolume,
        value: state.settings.defaultVolume,
        min: 0,
        max: 1,
        divisions: 20,
        valueLabel: '${(state.settings.defaultVolume * 100).round()}%',
        isDark: isDark,
        onChanged: (value) {
          context.read<SettingsBloc>().add(SettingsUpdateDefaultVolume(value));
        },
      ),
      _SliderTile(
        title: l10n.defaultSpeed,
        value: state.settings.defaultPlaybackSpeed,
        min: 0.5,
        max: 2,
        divisions: 6,
        valueLabel: '${state.settings.defaultPlaybackSpeed}x',
        isDark: isDark,
        onChanged: (value) {
          context.read<SettingsBloc>().add(SettingsUpdateDefaultSpeed(value));
        },
      ),
      _SwitchTile(
        title: l10n.autoResume,
        subtitle: l10n.autoResumeDesc,
        value: state.settings.autoResume,
        isDark: isDark,
        onChanged: (value) {
          context.read<SettingsBloc>().add(
            SettingsUpdateAutoResume(enabled: value),
          );
        },
      ),
      const SizedBox(height: AppSpacing.xl),
      _SectionHeader(title: l10n.skipSettings, isDark: isDark),
      _SliderTile(
        title: l10n.skipForward,
        value: state.settings.skipForwardSeconds.toDouble(),
        min: 5,
        max: 60,
        divisions: 11,
        valueLabel: l10n.seconds(state.settings.skipForwardSeconds),
        isDark: isDark,
        onChanged: (value) {
          context.read<SettingsBloc>().add(
            SettingsUpdateSkipForward(value.round()),
          );
        },
      ),
      _SliderTile(
        title: l10n.skipBackward,
        value: state.settings.skipBackwardSeconds.toDouble(),
        min: 5,
        max: 60,
        divisions: 11,
        valueLabel: l10n.seconds(state.settings.skipBackwardSeconds),
        isDark: isDark,
        onChanged: (value) {
          context.read<SettingsBloc>().add(
            SettingsUpdateSkipBackward(value.round()),
          );
        },
      ),
      const SizedBox(height: AppSpacing.xl),
      _SectionHeader(title: l10n.features, isDark: isDark),
      if (onSleepTimerPressed != null)
        _ActionTile(
          title: l10n.sleepTimer,
          subtitle: l10n.sleepTimerDesc,
          icon: Icons.bedtime_rounded,
          isDark: isDark,
          onTap: onSleepTimerPressed!,
        ),
      if (onFolderScanPressed != null)
        _ActionTile(
          title: l10n.scanFolders,
          subtitle: l10n.scanFoldersDesc,
          icon: Icons.folder_rounded,
          isDark: isDark,
          onTap: onFolderScanPressed!,
        ),
      const SizedBox(height: AppSpacing.xl),
      _SectionHeader(title: l10n.other, isDark: isDark),
      _ActionTile(
        title: l10n.resetSettings,
        subtitle: l10n.resetSettingsDesc,
        icon: Icons.settings_backup_restore_rounded,
        isDark: isDark,
        onTap: () => _confirmReset(context, l10n),
      ),
      _ActionTile(
        title: l10n.clearAllData,
        subtitle: l10n.clearAllDataDesc,
        icon: Icons.delete_forever_rounded,
        isDark: isDark,
        isDanger: true,
        onTap: () => _confirmResetAll(context, l10n),
      ),
      const SizedBox(height: AppSpacing.xxl),
      _AppInfo(isDark: isDark),
    ],
  );

  Future<void> _confirmReset(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? AppColors.gray900 : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              side: BorderSide(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
              ),
            ),
            title: Text(
              l10n.resetSettings,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            content: Text(
              l10n.resetSettingsConfirm,
              style: TextStyle(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.warning),
                child: Text(l10n.reset),
              ),
            ],
          ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<SettingsBloc>().add(const SettingsReset());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsReset),
          backgroundColor: AppColors.gray800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmResetAll(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? AppColors.gray900 : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              side: BorderSide(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
              ),
            ),
            title: Text(
              l10n.clearAllData,
              style: const TextStyle(color: AppColors.error),
            ),
            content: Text(
              l10n.clearAllDataConfirm,
              style: TextStyle(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(l10n.clearAllData),
              ),
            ],
          ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<SettingsBloc>().add(const SettingsResetAll());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allDataCleared),
          backgroundColor: AppColors.gray800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: isDark ? AppColors.white : AppColors.black,
              onPressed: onBack,
            ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            l10n.settings,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.black,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Text(
      title,
      style: TextStyle(
        color: isDark ? AppColors.gray400 : AppColors.gray600,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.isDark,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: isDark ? AppColors.gray900 : AppColors.gray100,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: isDark ? AppColors.gray800 : AppColors.gray200),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: isDark ? AppColors.gray500 : AppColors.gray600,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: isDark ? AppColors.white : AppColors.accent,
          activeTrackColor: isDark ? AppColors.gray600 : AppColors.accentLight,
          inactiveThumbColor: AppColors.gray400,
          inactiveTrackColor: isDark ? AppColors.gray800 : AppColors.gray300,
        ),
      ],
    ),
  );
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.currentLocale,
    required this.isDark,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String currentLocale;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isZh = currentLocale.startsWith('zh');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray900 : AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.gray800 : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? AppColors.gray500 : AppColors.gray600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  label: '繁體中文',
                  isSelected: isZh,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onTap: () => onChanged('zh_TW'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _LanguageOption(
                  label: 'English',
                  isSelected: !isZh,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  onTap: () => onChanged('en'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color:
            isSelected
                ? (isDark ? colorScheme.primary : colorScheme.primary)
                : (isDark ? AppColors.gray800 : AppColors.white),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color:
              isSelected
                  ? (isDark ? colorScheme.primary : colorScheme.primary)
                  : (isDark ? AppColors.gray700 : AppColors.gray300),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color:
              isSelected
                  ? (isDark ? AppColors.black : AppColors.white)
                  : (isDark ? AppColors.gray400 : AppColors.gray600),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    ),
  );
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.isDark,
    this.divisions,
    this.valueLabel,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? valueLabel;
  final bool isDark;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: isDark ? AppColors.gray900 : AppColors.gray100,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: isDark ? AppColors.gray800 : AppColors.gray200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (valueLabel != null)
              Text(
                valueLabel!,
                style: TextStyle(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: isDark ? AppColors.white : AppColors.accent,
            inactiveTrackColor: isDark ? AppColors.gray700 : AppColors.gray300,
            thumbColor: isDark ? AppColors.white : AppColors.accent,
            overlayColor: (isDark ? AppColors.white : AppColors.accent)
                .withValues(alpha: 0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.subtitle,
    this.isDanger = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDanger;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:
              _isHovered
                  ? (widget.isDark ? AppColors.gray800 : AppColors.gray200)
                  : (widget.isDark ? AppColors.gray900 : AppColors.gray100),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color:
                _isHovered
                    ? (widget.isDark ? AppColors.gray700 : AppColors.gray300)
                    : (widget.isDark ? AppColors.gray800 : AppColors.gray200),
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color:
                  widget.isDanger
                      ? AppColors.error
                      : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color:
                          widget.isDanger
                              ? AppColors.error
                              : (widget.isDark
                                  ? AppColors.white
                                  : AppColors.black),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        color:
                            widget.isDark
                                ? AppColors.gray500
                                : AppColors.gray600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: widget.isDark ? AppColors.gray600 : AppColors.gray400,
              size: 22,
            ),
          ],
        ),
      ),
    ),
  );
}

class _AppInfo extends StatelessWidget {
  const _AppInfo({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.appName,
          style: TextStyle(
            color: isDark ? AppColors.gray500 : AppColors.gray600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${l10n.version} 1.0.0',
          style: TextStyle(
            color: isDark ? AppColors.gray600 : AppColors.gray500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
