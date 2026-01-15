import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';

/// Animated equalizer bars that move like audio visualization
class AnimatedEqualizer extends StatefulWidget {
  const AnimatedEqualizer({
    super.key,
    this.color = AppColors.gray400,
    this.barCount = 3,
    this.barWidth = 3.0,
    this.maxHeight = 14.0,
    this.minHeight = 4.0,
    this.spacing = 2.0,
    this.isPlaying = true,
  });

  final Color color;
  final int barCount;
  final double barWidth;
  final double maxHeight;
  final double minHeight;
  final double spacing;
  final bool isPlaying;

  @override
  State<AnimatedEqualizer> createState() => _AnimatedEqualizerState();
}

class _AnimatedEqualizerState extends State<AnimatedEqualizer>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + _random.nextInt(400)),
      ),
    );

    _animations =
        _controllers
            .map(
              (controller) => Tween<double>(
                begin: widget.minHeight,
                end: widget.maxHeight,
              ).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
            )
            .toList();

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && widget.isPlaying) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (final controller in _controllers) {
      controller.stop();
    }
  }

  @override
  void didUpdateWidget(AnimatedEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
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
  Widget build(BuildContext context) => SizedBox(
    height: widget.maxHeight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        widget.barCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            right: index < widget.barCount - 1 ? widget.spacing : 0,
          ),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder:
                (context, child) => Container(
                  width: widget.barWidth,
                  height:
                      widget.isPlaying
                          ? _animations[index].value
                          : widget.minHeight + 2,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(widget.barWidth / 2),
                  ),
                ),
          ),
        ),
      ),
    ),
  );
}
