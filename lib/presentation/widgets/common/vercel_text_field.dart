import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';

/// A Vercel-style text field widget
class VercelTextField extends StatefulWidget {
  const VercelTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.isDark,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final TextAlign textAlign;
  final bool? isDark;

  @override
  State<VercelTextField> createState() => _VercelTextFieldState();
}

class _VercelTextFieldState extends State<VercelTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  bool _isDark(BuildContext context) => widget.isDark ?? context.isDarkMode;

  Color _borderColor(bool isDark) {
    if (widget.errorText != null) return AppColors.error;
    if (_isFocused) return isDark ? AppColors.white : AppColors.accent;
    return isDark ? AppColors.gray700 : AppColors.gray300;
  }

  Color _backgroundColor(bool isDark) {
    if (!widget.enabled) return isDark ? AppColors.gray900 : AppColors.gray100;
    return isDark ? AppColors.black : AppColors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium(
              isDark ? AppColors.gray300 : AppColors.gray600,
            ).copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: _backgroundColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: _borderColor(isDark)),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            textAlign: widget.textAlign,
            style: AppTypography.bodyMedium(
              isDark ? AppColors.white : AppColors.black,
            ),
            cursorColor: isDark ? AppColors.white : AppColors.accent,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodyMedium(
                isDark ? AppColors.gray500 : AppColors.gray400,
              ),
              prefixIcon: widget.prefixIcon,
              prefixIconColor: isDark ? AppColors.gray400 : AppColors.gray500,
              suffixIcon: widget.suffixIcon,
              suffixIconColor: isDark ? AppColors.gray400 : AppColors.gray500,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.bodySmall(AppColors.error),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.helperText!,
            style: AppTypography.bodySmall(
              isDark ? AppColors.gray500 : AppColors.gray600,
            ),
          ),
        ],
      ],
    );
  }
}
