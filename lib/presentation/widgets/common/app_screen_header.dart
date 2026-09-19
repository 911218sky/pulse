import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';

/// Shared header — large product title, ghost back control.
///
/// Nested screens (with [onBack]) hide the decorative [icon] so titles fit.
/// Prefer [AppHeaderActionButton] for trailing actions on narrow layouts.
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    required this.title,
    required this.isDark,
    super.key,
    this.icon,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;

  /// Optional leading glyph. Hidden automatically when [onBack] is set.
  final IconData? icon;

  /// Kept for call-site compatibility; theme comes from [BuildContext].
  final bool isDark;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    final palette = context.appPalette;
    final showIcon = icon != null && onBack == null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.md : AppSpacing.xl,
        isCompact ? AppSpacing.md : AppSpacing.lg,
        isCompact ? AppSpacing.md : AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _HeaderIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: onBack!,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
            ),
          if (showIcon) ...[
            Icon(icon, color: palette.mutedText, size: isCompact ? 22 : 24),
            SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      isCompact
                          ? AppTypography.headlineMedium(
                            palette.primaryText,
                          ).copyWith(fontSize: 18, fontWeight: FontWeight.w700)
                          : AppTypography.displaySmall(palette.primaryText),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(palette.secondaryText),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Circular icon action for dense headers (add / more / etc.).
class AppHeaderActionButton extends StatelessWidget {
  const AppHeaderActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
    this.filled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isDark = context.isDarkMode;

    return Tooltip(
      message: tooltip,
      child: Material(
        color:
            filled
                ? (isDark ? AppColors.white : AppColors.accent)
                : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 22,
              color:
                  filled
                      ? (isDark ? AppColors.black : AppColors.white)
                      : palette.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: palette.primaryText, size: 22),
          ),
        ),
      ),
    );
  }
}
