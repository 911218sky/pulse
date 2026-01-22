import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/utils/time_parser.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';
import 'package:pulse/presentation/widgets/common/app_toast.dart';
import 'package:pulse/presentation/widgets/playing_indicator.dart';

/// Screen showing playlist details with all tracks
class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({
    required this.playlistId,
    super.key,
    this.onBack,
  });

  final String playlistId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      body: SafeArea(
        child: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: (context, state) {
            final playlist =
                state.playlists.where((p) => p.id == playlistId).firstOrNull;

            if (playlist == null) {
              return Center(
                child: Text(
                  'Playlist not found',
                  style: TextStyle(
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              );
            }

            return Column(
              children: [
                _Header(
                  playlistName: playlist.name,
                  trackCount: playlist.fileCount,
                  onBack: onBack,
                  isDark: isDark,
                ),
                Expanded(child: _TrackList(playlist: playlist, isDark: isDark)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? AppColors.white : AppColors.accent,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        onPressed: () => _showAddSongsDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.addSongs,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _showAddSongsDialog(BuildContext context) async {
    final result = await _AddSongsDialog.show(context, playlistId);
    if (result != null && result.isNotEmpty && context.mounted) {
      context.read<PlaylistBloc>().add(
        PlaylistAddFiles(playlistId: playlistId, files: result),
      );
      AppToast.success(
        context,
        AppLocalizations.of(context).songsAdded(result.length),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.playlistName,
    required this.trackCount,
    required this.isDark,
    this.onBack,
  });

  final String playlistName;
  final int trackCount;
  final bool isDark;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? [
                    AppColors.black,
                    AppColors.gray900.withValues(alpha: 0.3),
                    AppColors.black,
                  ]
                  : [
                    AppColors.white,
                    AppColors.gray50.withValues(alpha: 0.5),
                    AppColors.white,
                  ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isCompact ? AppSpacing.md : AppSpacing.xl,
          isCompact ? AppSpacing.lg : AppSpacing.xxl,
          isCompact ? AppSpacing.md : AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (onBack != null)
                  Container(
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray900 : AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isDark ? AppColors.gray800 : AppColors.gray200,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: isDark ? AppColors.white : AppColors.black,
                      onPressed: onBack,
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(
                    isCompact ? AppSpacing.sm : AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                    borderRadius: BorderRadius.circular(
                      isCompact ? AppSpacing.radiusMd : AppSpacing.radiusLg,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.accent,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.queue_music_rounded,
                    color: AppColors.white,
                    size: isCompact ? 24 : 32,
                  ),
                ),
                SizedBox(width: isCompact ? AppSpacing.md : AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlistName,
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColors.black,
                          fontSize: isCompact ? 20 : 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.songsCount(trackCount),
                        style: TextStyle(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontSize: isCompact ? 13 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackList extends StatelessWidget {
  const _TrackList({required this.playlist, required this.isDark});

  final Playlist playlist;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (playlist.files.isEmpty) {
      return _EmptyState(isDark: isDark);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, playerState) {
        final currentTrackPath = playerState.currentAudio?.path;

        return ListView.builder(
          itemCount: playlist.files.length,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.md : AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          itemBuilder: (context, index) {
            final file = playlist.files[index];
            final isCurrentlyPlaying = currentTrackPath == file.path;
            final isActuallyPlaying =
                isCurrentlyPlaying && playerState.isPlaying;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.black : AppColors.gray400)
                        .withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _TrackTile(
                audioFile: file,
                index: index,
                playlistId: playlist.id,
                isDark: isDark,
                isCurrentlyPlaying: isCurrentlyPlaying,
                isActuallyPlaying: isActuallyPlaying,
              ),
            );
          },
        );
      },
    );
  }
}

class _TrackTile extends StatefulWidget {
  const _TrackTile({
    required this.audioFile,
    required this.index,
    required this.playlistId,
    required this.isDark,
    this.isCurrentlyPlaying = false,
    this.isActuallyPlaying = false,
  });

  final AudioFile audioFile;
  final int index;
  final String playlistId;
  final bool isDark;
  final bool isCurrentlyPlaying;
  final bool isActuallyPlaying;

  @override
  State<_TrackTile> createState() => _TrackTileState();
}

class _TrackTileState extends State<_TrackTile> {
  bool _isHovered = false;

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;

    showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? AppColors.gray900 : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              side: BorderSide(
                color: isDark ? AppColors.gray800 : AppColors.gray200,
              ),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.removeFromLibrary,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ),
            content: Text(
              'Remove "${widget.audioFile.displayTitle}" from playlist?',
              style: TextStyle(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(l10n.delete),
              ),
            ],
          ),
    ).then((confirmed) {
      if ((confirmed ?? false) && mounted) {
        context.read<PlaylistBloc>().add(
          PlaylistRemoveFile(
            playlistId: widget.playlistId,
            fileId: widget.audioFile.id,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    final isPlaying = widget.isCurrentlyPlaying;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Select playlist with the correct start index
          final currentPlaylistId =
              context.read<PlaylistBloc>().state.currentPlaylist?.id;
          if (currentPlaylistId != widget.playlistId) {
            // Different playlist - select it with the start index
            context.read<PlaylistBloc>().add(
              PlaylistSelect(widget.playlistId, startIndex: widget.index),
            );
          } else {
            // Same playlist - just jump to the track
            context.read<PlaylistBloc>().add(PlaylistJumpToTrack(widget.index));
          }

          context.read<PlayerBloc>().add(PlayerLoadAudio(widget.audioFile));
          context.push('/player');
        },
        onLongPress: _showDeleteDialog,
        onSecondaryTap: _showDeleteDialog,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color:
                isPlaying
                    ? (isDark
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.accent.withValues(alpha: 0.1))
                    : _isHovered
                    ? (isDark
                        ? AppColors.gray900
                        : AppColors.accent.withValues(alpha: 0.05))
                    : (isDark ? AppColors.gray900 : AppColors.white),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color:
                  isPlaying
                      ? AppColors.accent.withValues(alpha: 0.5)
                      : _isHovered
                      ? (isDark
                          ? AppColors.gray700
                          : AppColors.accent.withValues(alpha: 0.3))
                      : (isDark ? AppColors.gray800 : AppColors.gray200),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: isCompact ? 28 : 32,
                child:
                    isPlaying
                        ? PlayingIndicator(
                          color: AppColors.accent,
                          size: isCompact ? 18 : 20,
                          isAnimating: widget.isActuallyPlaying,
                        )
                        : _isHovered
                        ? Icon(
                          Icons.play_arrow_rounded,
                          color: isDark ? AppColors.white : AppColors.accent,
                          size: isCompact ? 18 : 20,
                        )
                        : Text(
                          '${widget.index + 1}',
                          style: TextStyle(
                            color:
                                isDark ? AppColors.gray500 : AppColors.gray400,
                            fontSize: isCompact ? 12 : 14,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
              ),
              SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
              Container(
                width: isCompact ? 40 : 48,
                height: isCompact ? 40 : 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isPlaying
                            ? [
                              AppColors.accent.withValues(alpha: 0.3),
                              AppColors.accentDark.withValues(alpha: 0.4),
                            ]
                            : isDark
                            ? [AppColors.gray800, AppColors.gray900]
                            : [
                              AppColors.accentLight.withValues(alpha: 0.2),
                              AppColors.accent.withValues(alpha: 0.3),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color:
                      isPlaying
                          ? AppColors.accent
                          : (isDark ? AppColors.gray600 : AppColors.accent),
                  size: isCompact ? 20 : 24,
                ),
              ),
              SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.audioFile.displayTitle,
                      style: TextStyle(
                        color:
                            isPlaying
                                ? AppColors.accent
                                : _isHovered
                                ? (isDark ? AppColors.white : AppColors.accent)
                                : (isDark
                                    ? AppColors.gray200
                                    : AppColors.black),
                        fontSize: isCompact ? 14 : 15,
                        fontWeight:
                            isPlaying ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.audioFile.artist ?? l10n.unknownArtist,
                      style: TextStyle(
                        color:
                            isPlaying
                                ? AppColors.accent.withValues(alpha: 0.7)
                                : (isDark
                                    ? AppColors.gray500
                                    : AppColors.gray600),
                        fontSize: isCompact ? 11 : 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: AppSpacing.md),
                Text(
                  widget.audioFile.duration > Duration.zero
                      ? TimeParser.formatDuration(widget.audioFile.duration)
                      : '--:--',
                  style: TextStyle(
                    color: isDark ? AppColors.gray500 : AppColors.gray500,
                    fontSize: 13,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color:
                    _isHovered
                        ? AppColors.error
                        : (isDark ? AppColors.gray600 : AppColors.gray400),
                iconSize: isCompact ? 18 : 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: isCompact ? 28 : 32,
                  minHeight: isCompact ? 28 : 32,
                ),
                onPressed: _showDeleteDialog,
                tooltip: l10n.removeFromLibrary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [AppColors.gray800, AppColors.gray900]
                        : [
                          AppColors.accentLight.withValues(alpha: 0.2),
                          AppColors.accent.withValues(alpha: 0.3),
                        ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isDark
                        ? AppColors.gray700
                        : AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.queue_music_rounded,
              color: isDark ? AppColors.gray500 : AppColors.accent,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.playlistEmpty,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.tapToAddSongs,
            style: TextStyle(
              color: isDark ? AppColors.gray500 : AppColors.gray600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for adding songs to a playlist
class _AddSongsDialog extends StatefulWidget {
  const _AddSongsDialog({required this.playlistId});

  final String playlistId;

  static Future<List<AudioFile>?> show(
    BuildContext context,
    String playlistId,
  ) => showModalBottomSheet<List<AudioFile>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddSongsDialog(playlistId: playlistId),
  );

  @override
  State<_AddSongsDialog> createState() => _AddSongsDialogState();
}

class _AddSongsDialogState extends State<_AddSongsDialog> {
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray900 : AppColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray700 : AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.addSongs,
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedIds.isNotEmpty)
                        Text(
                          l10n.selectedCount(_selectedIds.length),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _selectedIds.isEmpty ? null : _confirmSelection,
                  child: Text(
                    l10n.add,
                    style: TextStyle(
                      color:
                          _selectedIds.isEmpty
                              ? (isDark ? AppColors.gray600 : AppColors.gray400)
                              : AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: TextStyle(
                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                ),
                filled: true,
                fillColor: isDark ? AppColors.gray800 : AppColors.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Song list
          Expanded(
            child: BlocBuilder<FileScannerBloc, FileScannerState>(
              builder: (context, state) {
                final allFiles =
                    state.selectedFolders
                        .expand((folder) => folder.files)
                        .toList();

                // Get existing playlist files to exclude
                final playlistState = context.read<PlaylistBloc>().state;
                final playlist =
                    playlistState.playlists
                        .where((p) => p.id == widget.playlistId)
                        .firstOrNull;
                final existingIds =
                    playlist?.files.map((f) => f.id).toSet() ?? {};

                // Filter out already added songs and apply search
                var availableFiles =
                    allFiles.where((f) => !existingIds.contains(f.id)).toList();

                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  availableFiles =
                      availableFiles
                          .where(
                            (f) =>
                                f.displayTitle.toLowerCase().contains(query) ||
                                (f.artist?.toLowerCase().contains(query) ??
                                    false),
                          )
                          .toList();
                }

                if (availableFiles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_off_rounded,
                          color: isDark ? AppColors.gray600 : AppColors.gray400,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _searchQuery.isNotEmpty
                              ? l10n.noResults
                              : l10n.noSongsAvailable,
                          style: TextStyle(
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: availableFiles.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemBuilder: (context, index) {
                    final file = availableFiles[index];
                    final isSelected = _selectedIds.contains(file.id);

                    return _SongSelectTile(
                      audioFile: file,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(file.id);
                          } else {
                            _selectedIds.add(file.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    final state = context.read<FileScannerBloc>().state;
    final allFiles =
        state.selectedFolders.expand((folder) => folder.files).toList();
    final selectedFiles =
        allFiles.where((f) => _selectedIds.contains(f.id)).toList();
    Navigator.pop(context, selectedFiles);
  }
}

class _SongSelectTile extends StatelessWidget {
  const _SongSelectTile({
    required this.audioFile,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final AudioFile audioFile;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border:
              isSelected
                  ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
                  : null,
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isSelected
                          ? AppColors.accent
                          : (isDark ? AppColors.gray600 : AppColors.gray400),
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 16,
                      )
                      : null,
            ),
            const SizedBox(width: AppSpacing.md),
            // Album art placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [AppColors.gray800, AppColors.gray900]
                          : [
                            AppColors.accentLight.withValues(alpha: 0.2),
                            AppColors.accent.withValues(alpha: 0.3),
                          ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.music_note_rounded,
                color: isDark ? AppColors.gray600 : AppColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Title and artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audioFile.displayTitle,
                    style: TextStyle(
                      color:
                          isSelected
                              ? AppColors.accent
                              : (isDark ? AppColors.gray200 : AppColors.black),
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    audioFile.artist ?? l10n.unknownArtist,
                    style: TextStyle(
                      color: isDark ? AppColors.gray500 : AppColors.gray600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
