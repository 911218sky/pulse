import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';

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

  Color get _backgroundColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    if (widget.isSelected) return AppColors.gray900;
    if (_isHovered && widget.onTap != null) return AppColors.gray900;
    return AppColors.black;
  }

  Color get _borderColor {
    if (widget.isSelected) return AppColors.white;
    if (_isHovered && widget.onTap != null) return AppColors.gray600;
    return AppColors.gray800;
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
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: widget.showBorder ? Border.all(color: _borderColor) : null,
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
  Widget build(BuildContext context) => VercelCard(
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
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  child: title!,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                DefaultTextStyle(
                  style: const TextStyle(
                    color: AppColors.gray400,
                    fontSize: 13,
                  ),
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
