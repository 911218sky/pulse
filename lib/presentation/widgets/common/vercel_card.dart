import 'package:flutter/material.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';

/// Visual density for list rows.
enum VercelListTileStyle {
  /// Bordered card (settings / panels).
  card,

  /// Inset divider rows (music library — Spotify-like dense list).
  inset,
}

/// A Vercel-style card widget
class VercelCard extends StatefulWidget {
  const VercelCard({
    super.key,
    this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showBorder = true,
    this.backgroundColor,
    this.borderRadius,
  });

  final Widget? child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showBorder;
  final Color? backgroundColor;
  final double? borderRadius;

  @override
  State<VercelCard> createState() => _VercelCardState();
}

class _VercelCardState extends State<VercelCard> {
  bool _isHovered = false;

  Color _backgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    final palette = context.appPalette;
    if (widget.isSelected) return palette.rowActive;
    if (_isHovered && widget.onTap != null) return palette.rowHover;
    return palette.surface;
  }

  Color _borderColor(BuildContext context) {
    final palette = context.appPalette;
    if (widget.isSelected) return AppColorsAccent.border(context);
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
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _backgroundColor(context),
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? AppSpacing.radiusMd,
          ),
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

/// Accent helpers without coupling card to AppColors import noise.
class AppColorsAccent {
  static Color border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF0070F3).withValues(alpha: 0.45)
        : const Color(0xFF0070F3).withValues(alpha: 0.35);
  }
}

/// List tile for music rows and settings-style lists.
class VercelListTile extends StatelessWidget {
  const VercelListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.dense = false,
    this.style = VercelListTileStyle.card,
    this.contentPadding,
    this.showBottomDivider = false,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool dense;
  final VercelListTileStyle style;
  final EdgeInsets? contentPadding;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isInset = style == VercelListTileStyle.inset;
    final padding =
        contentPadding ??
        EdgeInsets.symmetric(
          horizontal: dense ? AppSpacing.sm : AppSpacing.md,
          vertical: dense ? AppSpacing.mdSm : AppSpacing.md,
        );

    final row = Row(
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: dense ? AppSpacing.sm : AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                DefaultTextStyle(
                  style: AppTypography.labelLarge(palette.primaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: title!,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                DefaultTextStyle(
                  style: AppTypography.bodySmall(palette.secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: subtitle!,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: dense ? AppSpacing.sm : AppSpacing.md),
          trailing!,
        ],
      ],
    );

    if (isInset) {
      return _InsetRow(
        onTap: onTap,
        onLongPress: onLongPress,
        isSelected: isSelected,
        padding: padding,
        showBottomDivider: showBottomDivider,
        child: row,
      );
    }

    return VercelCard(
      padding: padding,
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      child: row,
    );
  }
}

class _InsetRow extends StatefulWidget {
  const _InsetRow({
    required this.child,
    required this.padding,
    required this.isSelected,
    required this.showBottomDivider,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool isSelected;
  final bool showBottomDivider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<_InsetRow> createState() => _InsetRowState();
}

class _InsetRowState extends State<_InsetRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    // Selected = subtle wash only; never filled accent block.
    final bg =
        widget.isSelected
            ? palette.rowHover
            : _hovered && widget.onTap != null
            ? palette.rowHover
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor:
          widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            AnimatedContainer(
              duration: AppDurations.fast,
              color: bg,
              padding: widget.padding,
              child: widget.child,
            ),
            if (widget.showBottomDivider)
              Divider(height: 1, thickness: 1, color: palette.divider),
          ],
        ),
      ),
    );
  }
}
