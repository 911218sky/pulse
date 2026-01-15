import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/utils/time_parser.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// A single item in a playlist
class PlaylistItem extends StatefulWidget {
  const PlaylistItem({
    required this.audioFile,
    required this.index,
    super.key,
    this.isPlaying = false,
    this.isSelected = false,
    this.onTap,
    this.onDoubleTap,
    this.onRemove,
    this.showIndex = true,
    this.showDuration = true,
    this.showArtist = true,
    this.dragHandle,
  });

  final AudioFile audioFile;
  final int index;
  final bool isPlaying;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onRemove;
  final bool showIndex;
  final bool showDuration;
  final bool showArtist;
  final Widget? dragHandle;

  @override
  State<PlaylistItem> createState() => _PlaylistItemState();
}

class _PlaylistItemState extends State<PlaylistItem> {
  bool _isHovered = false;

  Color get _backgroundColor {
    if (widget.isPlaying) return AppColors.gray800;
    if (widget.isSelected) return AppColors.gray900;
    if (_isHovered) return AppColors.gray900;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          children: [
            // Drag handle
            if (widget.dragHandle != null) ...[
              widget.dragHandle!,
              const SizedBox(width: AppSpacing.sm),
            ],

            // Index or playing indicator
            if (widget.showIndex)
              SizedBox(
                width: 32,
                child:
                    widget.isPlaying
                        ? const _PlayingIndicator()
                        : Text(
                          '${widget.index + 1}',
                          style: const TextStyle(
                            color: AppColors.gray500,
                            fontSize: 13,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
              ),

            // Title and artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.audioFile.displayTitle,
                    style: TextStyle(
                      color:
                          widget.isPlaying
                              ? AppColors.white
                              : AppColors.gray200,
                      fontSize: 14,
                      fontWeight:
                          widget.isPlaying
                              ? FontWeight.w500
                              : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.showArtist && widget.audioFile.artist != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.audioFile.artist!,
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Duration
            if (widget.showDuration)
              Text(
                widget.audioFile.duration == Duration.zero
                    ? '--:--'
                    : TimeParser.formatDuration(widget.audioFile.duration),
                style: const TextStyle(
                  color: AppColors.gray500,
                  fontSize: 13,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),

            // Remove button
            if (_isHovered && widget.onRemove != null) ...[
              const SizedBox(width: AppSpacing.sm),
              _RemoveButton(onTap: widget.onRemove!),
            ],
          ],
        ),
      ),
    ),
  );
}

class _PlayingIndicator extends StatefulWidget {
  const _PlayingIndicator();

  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder:
        (context, child) => SizedBox(
          width: 16,
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => Container(
                width: 3,
                height: 4 + (_controller.value * 8 * (index.isEven ? 1 : 0.5)),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
  );
}

class _RemoveButton extends StatefulWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_RemoveButton> createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<_RemoveButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.gray700 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.gray400,
          size: 16,
        ),
      ),
    ),
  );
}
