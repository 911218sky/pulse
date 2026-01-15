import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/utils/time_parser.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';

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
    );
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

    return ListView.builder(
      itemCount: playlist.files.length,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppSpacing.md : AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        final file = playlist.files[index];
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
          ),
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
  });

  final AudioFile audioFile;
  final int index;
  final String playlistId;
  final bool isDark;

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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<PlaylistBloc>()
            ..add(PlaylistSelect(widget.playlistId))
            ..add(PlaylistJumpToTrack(widget.index));
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
                _isHovered
                    ? (isDark
                        ? AppColors.gray900
                        : AppColors.accent.withValues(alpha: 0.05))
                    : (isDark ? AppColors.gray900 : AppColors.white),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color:
                  _isHovered
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
                    _isHovered
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
                        isDark
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
                  color: isDark ? AppColors.gray600 : AppColors.accent,
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
                            _isHovered
                                ? (isDark ? AppColors.white : AppColors.accent)
                                : (isDark
                                    ? AppColors.gray200
                                    : AppColors.black),
                        fontSize: isCompact ? 14 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.audioFile.artist ?? l10n.unknownArtist,
                      style: TextStyle(
                        color: isDark ? AppColors.gray500 : AppColors.gray600,
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
        ],
      ),
    );
  }
}
