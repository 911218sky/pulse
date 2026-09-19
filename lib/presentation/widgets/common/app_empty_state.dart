import 'package:flutter/material.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';

/// Empty-state: title + muted subtitle + optional pill CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final hasAction = actionLabel != null && onAction != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: palette.mutedText, size: 48),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.headlineLarge(palette.primaryText),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(palette.secondaryText),
                ),
              ],
              if (hasAction) ...[
                const SizedBox(height: AppSpacing.lg),
                VercelButton(
                  label: actionLabel,
                  icon: actionIcon,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
