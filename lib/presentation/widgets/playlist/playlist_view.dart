import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/presentation/widgets/playlist/playlist_item.dart';

/// A view for displaying and managing a playlist
class PlaylistView extends StatelessWidget {
  const PlaylistView({
    required this.playlist,
    super.key,
    this.currentTrackIndex,
    this.onTrackTap,
    this.onTrackDoubleTap,
    this.onTrackRemove,
    this.onReorder,
    this.showDragHandles = false,
  });

  final Playlist playlist;
  final int? currentTrackIndex;
  final void Function(int index)? onTrackTap;
  final void Function(int index)? onTrackDoubleTap;
  final void Function(int index)? onTrackRemove;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final bool showDragHandles;

  @override
  Widget build(BuildContext context) {
    if (playlist.isEmpty) {
      return const _EmptyPlaylist();
    }

    if (onReorder != null) {
      return _ReorderablePlaylistView(
        playlist: playlist,
        currentTrackIndex: currentTrackIndex,
        onTrackTap: onTrackTap,
        onTrackDoubleTap: onTrackDoubleTap,
        onTrackRemove: onTrackRemove,
        onReorder: onReorder!,
        showDragHandles: showDragHandles,
      );
    }

    return ListView.builder(
      itemCount: playlist.fileCount,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemBuilder:
          (context, index) => PlaylistItem(
            audioFile: playlist.files[index],
            index: index,
            isPlaying: index == currentTrackIndex,
            onTap: onTrackTap != null ? () => onTrackTap!(index) : null,
            onDoubleTap:
                onTrackDoubleTap != null
                    ? () => onTrackDoubleTap!(index)
                    : null,
            onRemove:
                onTrackRemove != null ? () => onTrackRemove!(index) : null,
          ),
    );
  }
}

class _ReorderablePlaylistView extends StatelessWidget {
  const _ReorderablePlaylistView({
    required this.playlist,
    required this.onReorder,
    this.currentTrackIndex,
    this.onTrackTap,
    this.onTrackDoubleTap,
    this.onTrackRemove,
    this.showDragHandles = false,
  });

  final Playlist playlist;
  final int? currentTrackIndex;
  final void Function(int index)? onTrackTap;
  final void Function(int index)? onTrackDoubleTap;
  final void Function(int index)? onTrackRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final bool showDragHandles;

  @override
  Widget build(BuildContext context) => ReorderableListView.builder(
    itemCount: playlist.fileCount,
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    proxyDecorator:
        (child, index, animation) => Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.gray800,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
    onReorder: (oldIndex, newIndex) {
      // Adjust for the way ReorderableListView handles indices
      if (newIndex > oldIndex) newIndex--;
      onReorder(oldIndex, newIndex);
    },
    itemBuilder:
        (context, index) => PlaylistItem(
          key: ValueKey(playlist.files[index].id),
          audioFile: playlist.files[index],
          index: index,
          isPlaying: index == currentTrackIndex,
          onTap: onTrackTap != null ? () => onTrackTap!(index) : null,
          onDoubleTap:
              onTrackDoubleTap != null ? () => onTrackDoubleTap!(index) : null,
          onRemove: onTrackRemove != null ? () => onTrackRemove!(index) : null,
          dragHandle:
              showDragHandles
                  ? ReorderableDragStartListener(
                    index: index,
                    child: const Icon(
                      Icons.drag_handle_rounded,
                      color: AppColors.gray500,
                      size: 20,
                    ),
                  )
                  : null,
        ),
  );
}

class _EmptyPlaylist extends StatelessWidget {
  const _EmptyPlaylist();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.queue_music_rounded,
            color: AppColors.gray600,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.playlistEmpty,
            style: const TextStyle(color: AppColors.gray500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// A compact playlist header showing info and controls
class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader({
    required this.playlist,
    super.key,
    this.onShuffle,
    this.onRepeat,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
  });

  final Playlist playlist;
  final VoidCallback? onShuffle;
  final VoidCallback? onRepeat;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playlist.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${playlist.fileCount} 首歌曲',
                style: const TextStyle(color: AppColors.gray500, fontSize: 13),
              ),
            ],
          ),
        ),
        if (onShuffle != null)
          _ControlButton(
            icon: Icons.shuffle_rounded,
            isActive: shuffleEnabled,
            onTap: onShuffle!,
          ),
        if (onRepeat != null) ...[
          const SizedBox(width: AppSpacing.sm),
          _ControlButton(
            icon: _repeatIcon,
            isActive: repeatMode != RepeatMode.off,
            onTap: onRepeat!,
          ),
        ],
      ],
    ),
  );

  IconData get _repeatIcon => switch (repeatMode) {
    RepeatMode.off => Icons.repeat_rounded,
    RepeatMode.all => Icons.repeat_rounded,
    RepeatMode.one => Icons.repeat_one_rounded,
  };
}

/// Repeat mode options
enum RepeatMode { off, all, one }

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.gray800 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          widget.icon,
          color: widget.isActive ? AppColors.white : AppColors.gray500,
          size: 20,
        ),
      ),
    ),
  );
}
