import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';

/// Vercel-style button variants
enum VercelButtonVariant { primary, secondary, ghost, danger }

/// Vercel-style button sizes
enum VercelButtonSize { small, medium, large }

/// A Vercel-style button widget
class VercelButton extends StatefulWidget {
  const VercelButton({
    required this.onPressed,
    super.key,
    this.label,
    this.icon,
    this.variant = VercelButtonVariant.primary,
    this.size = VercelButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.isDark,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final VercelButtonVariant variant;
  final VercelButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final bool? isDark;

  @override
  State<VercelButton> createState() => _VercelButtonState();
}

class _VercelButtonState extends State<VercelButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading;

  bool _isDark(BuildContext context) =>
      widget.isDark ?? Theme.of(context).brightness == Brightness.dark;

  double get _height => switch (widget.size) {
    VercelButtonSize.small => 32,
    VercelButtonSize.medium => 40,
    VercelButtonSize.large => 48,
  };

  EdgeInsets get _padding => switch (widget.size) {
    VercelButtonSize.small => const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
    ),
    VercelButtonSize.medium => const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
    ),
    VercelButtonSize.large => const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
    ),
  };

  double get _fontSize => switch (widget.size) {
    VercelButtonSize.small => 13,
    VercelButtonSize.medium => 14,
    VercelButtonSize.large => 16,
  };

  double get _iconSize => switch (widget.size) {
    VercelButtonSize.small => 16,
    VercelButtonSize.medium => 18,
    VercelButtonSize.large => 20,
  };

  Color _backgroundColor(bool isDark) {
    if (!_isEnabled) {
      return switch (widget.variant) {
        VercelButtonVariant.primary => AppColors.gray700,
        VercelButtonVariant.secondary =>
          isDark ? AppColors.gray900 : AppColors.gray200,
        VercelButtonVariant.ghost => Colors.transparent,
        VercelButtonVariant.danger => AppColors.gray700,
      };
    }

    if (_isPressed) {
      return switch (widget.variant) {
        VercelButtonVariant.primary =>
          isDark ? AppColors.gray200 : AppColors.accentDark,
        VercelButtonVariant.secondary =>
          isDark ? AppColors.gray700 : AppColors.gray300,
        VercelButtonVariant.ghost =>
          isDark ? AppColors.gray800 : AppColors.gray200,
        VercelButtonVariant.danger => AppColors.errorDark,
      };
    }

    if (_isHovered) {
      return switch (widget.variant) {
        VercelButtonVariant.primary =>
          isDark ? AppColors.gray100 : AppColors.accentLight,
        VercelButtonVariant.secondary =>
          isDark ? AppColors.gray800 : AppColors.gray200,
        VercelButtonVariant.ghost =>
          isDark ? AppColors.gray900 : AppColors.gray100,
        VercelButtonVariant.danger => AppColors.error,
      };
    }

    return switch (widget.variant) {
      VercelButtonVariant.primary =>
        isDark ? AppColors.white : AppColors.accent,
      VercelButtonVariant.secondary =>
        isDark ? AppColors.gray900 : AppColors.gray100,
      VercelButtonVariant.ghost => Colors.transparent,
      VercelButtonVariant.danger => AppColors.error,
    };
  }

  Color _foregroundColor(bool isDark) {
    if (!_isEnabled) return AppColors.gray500;

    return switch (widget.variant) {
      VercelButtonVariant.primary => isDark ? AppColors.black : AppColors.white,
      VercelButtonVariant.secondary =>
        isDark ? AppColors.white : AppColors.black,
      VercelButtonVariant.ghost =>
        isDark ? AppColors.gray300 : AppColors.gray700,
      VercelButtonVariant.danger => AppColors.white,
    };
  }

  Color _borderColor(bool isDark) {
    if (!_isEnabled) return isDark ? AppColors.gray700 : AppColors.gray300;

    return switch (widget.variant) {
      VercelButtonVariant.primary => Colors.transparent,
      VercelButtonVariant.secondary =>
        _isHovered
            ? (isDark ? AppColors.gray600 : AppColors.gray400)
            : (isDark ? AppColors.gray700 : AppColors.gray300),
      VercelButtonVariant.ghost => Colors.transparent,
      VercelButtonVariant.danger => Colors.transparent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel:
            _isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          height: _height,
          constraints:
              widget.fullWidth
                  ? const BoxConstraints(minWidth: double.infinity)
                  : null,
          padding: _padding,
          decoration: BoxDecoration(
            color: _backgroundColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: _borderColor(isDark)),
          ),
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: _iconSize,
                  height: _iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      _foregroundColor(isDark),
                    ),
                  ),
                )
              else if (widget.icon != null)
                Icon(
                  widget.icon,
                  size: _iconSize,
                  color: _foregroundColor(isDark),
                ),
              if ((widget.icon != null || widget.isLoading) &&
                  widget.label != null)
                const SizedBox(width: AppSpacing.sm),
              if (widget.label != null)
                Flexible(
                  child: Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w500,
                      color: _foregroundColor(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
