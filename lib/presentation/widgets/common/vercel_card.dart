import 'package:flutter/material.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';

/// A Vercel-style card widget
class VercelCard extends StatefulWidget {
  const VercelCard({
    super.key,
    this.child,
    this.padding,
    this.onTap,
    this.isSelected = false,
    this.showBorder = true,
    this.backgroundColor,
  });

  final Widget? child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showBorder;
  final Color? backgroundColor;

  @override
  State<VercelCard> createState() => _VercelCardState();
}

class _VercelCardState extends State<VercelCard> {
  bool _isHovered = false;

  Color _backgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    final palette = context.appPalette;
    if (widget.isSelected) return palette.elevatedSurface;
    if (_isHovered && widget.onTap != null) return palette.surface;
    return palette.background;
  }

  Color _borderColor(BuildContext context) {
    final palette = context.appPalette;
    if (widget.isSelected) return Theme.of(context).colorScheme.primary;
    if (_isHovered && widget.onTap != null) return palette.border;
    return palette.subtleBorder;
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
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
        padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _backgroundColor(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border:
              widget.showBorder
                  ? Border.all(color: _borderColor(context))
                  : null,
        ),
        child: widget.child,
      ),
    ),
  );
}

/// A Vercel-style list tile for use in cards
class VercelListTile extends StatelessWidget {
  const VercelListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return VercelCard(
      padding: contentPadding ?? const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: AppTypography.labelLarge(palette.primaryText),
                    child: title!,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  DefaultTextStyle(
                    style: AppTypography.bodySmall(palette.secondaryText),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}
