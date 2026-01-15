import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/utils/volume_utils.dart';

/// A Vercel-style volume slider widget
class VolumeSlider extends StatefulWidget {
  const VolumeSlider({
    required this.volume,
    required this.onChanged,
    super.key,
    this.isMuted = false,
    this.onMuteToggle,
    this.showIcon = true,
    this.width = 120,
    this.orientation = Axis.horizontal,
  });

  final double volume;
  final ValueChanged<double> onChanged;
  final bool isMuted;
  final VoidCallback? onMuteToggle;
  final bool showIcon;
  final double width;
  final Axis orientation;

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  bool _isHovered = false;
  bool _isDragging = false;
  double _dragValue = 0;

  double get _displayVolume {
    if (widget.isMuted) return 0;
    if (_isDragging) return _dragValue;
    return widget.volume;
  }

  IconData get _volumeIcon {
    if (widget.isMuted || _displayVolume == 0) {
      return Icons.volume_off_rounded;
    }
    if (_displayVolume < 0.3) {
      return Icons.volume_mute_rounded;
    }
    if (_displayVolume < 0.7) {
      return Icons.volume_down_rounded;
    }
    return Icons.volume_up_rounded;
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragValue = widget.volume;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, double maxExtent) {
    final delta =
        widget.orientation == Axis.horizontal
            ? details.delta.dx / maxExtent
            : -details.delta.dy / maxExtent;
    final newValue = VolumeUtils.clamp(_dragValue + delta);
    setState(() => _dragValue = newValue);
    widget.onChanged(newValue);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
  }

  void _onTap(TapUpDetails details, double maxExtent) {
    final position =
        widget.orientation == Axis.horizontal
            ? details.localPosition.dx / maxExtent
            : 1 - (details.localPosition.dy / maxExtent);
    final newVolume = VolumeUtils.clamp(position);
    widget.onChanged(newVolume);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orientation == Axis.vertical) {
      return _buildVerticalSlider();
    }
    return _buildHorizontalSlider();
  }

  Widget _buildHorizontalSlider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcon)
          _VolumeIconButton(
            icon: _volumeIcon,
            onTap: widget.onMuteToggle,
            isDark: isDark,
          ),
        if (widget.showIcon) const SizedBox(width: AppSpacing.sm),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate:
                (details) => _onDragUpdate(details, widget.width),
            onHorizontalDragEnd: _onDragEnd,
            onTapUp: (details) => _onTap(details, widget.width),
            child: SizedBox(
              width: widget.width,
              height: 24,
              child: _buildSliderTrack(isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalSlider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onVerticalDragStart: _onDragStart,
            onVerticalDragUpdate:
                (details) => _onDragUpdate(details, widget.width),
            onVerticalDragEnd: _onDragEnd,
            onTapUp: (details) => _onTap(details, widget.width),
            child: SizedBox(
              width: 24,
              height: widget.width,
              child: _buildVerticalSliderTrack(isDark),
            ),
          ),
        ),
        if (widget.showIcon) const SizedBox(height: AppSpacing.sm),
        if (widget.showIcon)
          _VolumeIconButton(
            icon: _volumeIcon,
            onTap: widget.onMuteToggle,
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildSliderTrack(bool isDark) => Center(
    child: AnimatedContainer(
      duration: AppDurations.fast,
      height: _isHovered || _isDragging ? 6 : 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background track
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray700 : AppColors.gray300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Volume level
          FractionallySizedBox(
            widthFactor: _displayVolume.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.white : AppColors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Thumb
          if (_isHovered || _isDragging)
            Positioned(
              left: (_displayVolume.clamp(0.0, 1.0) * widget.width) - 6,
              top: -3,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white : AppColors.blue,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildVerticalSliderTrack(bool isDark) => Center(
    child: AnimatedContainer(
      duration: AppDurations.fast,
      width: _isHovered || _isDragging ? 6 : 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background track
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray700 : AppColors.gray300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Volume level
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: _displayVolume.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white : AppColors.blue,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          // Thumb
          if (_isHovered || _isDragging)
            Positioned(
              left: -3,
              bottom: (_displayVolume.clamp(0.0, 1.0) * widget.width) - 6,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white : AppColors.blue,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _VolumeIconButton extends StatefulWidget {
  const _VolumeIconButton({
    required this.icon,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  State<_VolumeIconButton> createState() => _VolumeIconButtonState();
}

class _VolumeIconButtonState extends State<_VolumeIconButton> {
  bool _isHovered = false;

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
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color:
              _isHovered
                  ? (widget.isDark ? AppColors.gray800 : AppColors.gray200)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          widget.icon,
          color: widget.isDark ? AppColors.gray300 : AppColors.gray600,
          size: 20,
        ),
      ),
    ),
  );
}
