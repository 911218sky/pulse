import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';

/// Shared header block used across primary screens.
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    required this.title,
    required this.icon,
    required this.isDark,
    super.key,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isDark;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    final palette = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? [
                    AppColors.black,
                    AppColors.gray900.withValues(alpha: 0.28),
                    AppColors.black,
                  ]
                  : [
                    AppColors.white,
                    AppColors.gray50.withValues(alpha: 0.48),
                    AppColors.white,
                  ],
          stops: const [0.0, 0.28, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isCompact ? AppSpacing.md : AppSpacing.xl,
          isCompact ? AppSpacing.lg : AppSpacing.xxl,
          isCompact ? AppSpacing.md : AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -24,
              child: Container(
                width: isCompact ? 92 : 132,
                height: isCompact ? 92 : 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(
                    alpha: isDark ? 0.12 : 0.08,
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onBack != null)
                  Container(
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray900 : AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isDark ? AppColors.gray800 : AppColors.gray200,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: palette.primaryText,
                      onPressed: onBack,
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(
                    isCompact ? AppSpacing.sm : AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                    borderRadius: BorderRadius.circular(
                      isCompact ? AppSpacing.radiusMd : AppSpacing.radiusLg,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.white,
                    size: isCompact ? 24 : 32,
                  ),
                ),
                SizedBox(width: isCompact ? AppSpacing.md : AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            isCompact
                                ? AppTypography.displaySmall(
                                  palette.primaryText,
                                )
                                : AppTypography.displayMedium(
                                  palette.primaryText,
                                ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium(
                            palette.secondaryText,
                          ),
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
          ],
        ),
      ),
    );
  }
}
