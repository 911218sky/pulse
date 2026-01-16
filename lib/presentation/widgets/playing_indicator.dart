import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';

/// Animated playing indicator with bouncing bars
class PlayingIndicator extends StatefulWidget {
  const PlayingIndicator({
    super.key,
    this.color,
    this.size = 20,
    this.barCount = 3,
  });

  final Color? color;
  final double size;
  final int barCount;

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    _animations =
        _controllers
            .map(
              (controller) => Tween<double>(begin: 0.3, end: 1).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
            )
            .toList();

    // Start animations with staggered delays
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.accent;
    final barWidth = widget.size / (widget.barCount * 2);
    final gap = barWidth * 0.5;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          widget.barCount,
          (index) => AnimatedBuilder(
            animation: _animations[index],
            builder:
                (context, child) => Container(
                  width: barWidth,
                  height: widget.size * _animations[index].value,
                  margin: EdgeInsets.only(
                    right: index < widget.barCount - 1 ? gap : 0,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(barWidth / 2),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
