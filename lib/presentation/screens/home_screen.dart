import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/utils/time_parser.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_event.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/bloc/search/search_event.dart';
import 'package:pulse/presentation/bloc/search/search_state.dart';
import 'package:pulse/presentation/widgets/common/app_toast.dart';
import 'package:pulse/presentation/widgets/common/vercel_text_field.dart';

/// Home screen showing the music library
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onTrackSelected,
    this.onSettingsPressed,
    this.onScanPressed,
    this.onPlaylistPressed,
  });

  final void Function(AudioFile file)? onTrackSelected;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onScanPressed;
  final VoidCallback? onPlaylistPressed;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFilesFromScanner();
    });
  }

  void _syncFilesFromScanner() {
    final scannerState = context.read<FileScannerBloc>().state;
    if (scannerState.status == FileScannerStatus.completed) {
      final allFiles =
          scannerState.selectedFolders
              .expand((folder) => folder.files)
              .toList();
      if (allFiles.isNotEmpty) {
        context.read<SearchBloc>().add(SearchSourceUpdated(allFiles));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<FileScannerBloc, FileScannerState>(
      listenWhen:
          (previous, current) =>
              previous.folders != current.folders ||
              previous.libraryFiles != current.libraryFiles,
      listener: (context, state) {
        // Sync files to SearchBloc when FileScannerBloc state changes
        final allFiles =
            state.selectedFolders.expand((folder) => folder.files).toList();
        context.read<SearchBloc>().add(SearchSourceUpdated(allFiles));
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.black : AppColors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  onSettingsPressed: widget.onSettingsPressed,
                  onScanPressed: widget.onScanPressed,
                  onPlaylistPressed: widget.onPlaylistPressed,
                  isDark: isDark,
                ),
              ),
              SliverToBoxAdapter(child: _SearchBar(isDark: isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              _SliverMusicList(
                onTrackSelected: widget.onTrackSelected,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isDark,
    this.onSettingsPressed,
    this.onScanPressed,
    this.onPlaylistPressed,
  });

  final bool isDark;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onScanPressed;
  final VoidCallback? onPlaylistPressed;

  static void _showClearLibraryDialog(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

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
                  l10n.clearLibrary,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ),
            content: Text(
              l10n.clearLibraryConfirm,
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
      if ((confirmed ?? false) && context.mounted) {
        context.read<FileScannerBloc>().add(const FileScannerClearLibrary());
        // Clear SearchBloc as well
        context.read<SearchBloc>().add(const SearchSourceUpdated([]));
        AppToast.success(context, l10n.libraryCleared);
      }
    });
  }

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
            // Hero section with title and subtitle
            _buildHeroSection(context, l10n, isCompact),
            SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),

            // Action buttons section
            _buildActionSection(context, l10n, isCompact),

            SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isCompact,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Main title with icon
      Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
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
              Icons.library_music_rounded,
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
                  l10n.musicLibrary,
                  style: TextStyle(
                    color: isDark ? AppColors.white : AppColors.black,
                    fontSize: isCompact ? 24 : 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.exploreYourMusic,
                  style: TextStyle(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Settings button for mobile
          if (isCompact && onSettingsPressed != null)
            _ModernIconButton(
              icon: Icons.settings_rounded,
              onTap: onSettingsPressed!,
              tooltip: l10n.settings,
              isDark: isDark,
            ),
        ],
      ),
    ],
  );

  Widget _buildActionSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isCompact,
  ) {
    if (isCompact) {
      return Column(
        children: [
          // Primary actions
          Row(
            children: [
              if (onPlaylistPressed != null)
                Expanded(
                  child: _ModernActionCard(
                    icon: Icons.queue_music_rounded,
                    title: l10n.playlist,
                    subtitle: l10n.managePlaylist,
                    onTap: onPlaylistPressed!,
                    isDark: isDark,
                    color: AppColors.accent,
                  ),
                ),
              if (onPlaylistPressed != null && onScanPressed != null)
                const SizedBox(width: AppSpacing.md),
              if (onScanPressed != null)
                Expanded(
                  child: _ModernActionCard(
                    icon: Icons.refresh_rounded,
                    title: l10n.refreshLibrary,
                    subtitle: l10n.scanNewMusic,
                    onTap: onScanPressed!,
                    isDark: isDark,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ),
          // Secondary actions
          if (onScanPressed != null) ...[
            const SizedBox(height: AppSpacing.md),
            _ModernActionCard(
              icon: Icons.delete_sweep_rounded,
              title: l10n.clearLibrary,
              subtitle: l10n.clearLibraryDesc,
              onTap: () => _showClearLibraryDialog(context, isDark),
              isDark: isDark,
              color: AppColors.error,
              isDestructive: true,
              isFullWidth: true,
            ),
          ],
        ],
      );
    } else {
      // Desktop layout with floating action bar
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.gray900.withValues(alpha: 0.8)
                  : AppColors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.gray800 : AppColors.gray200,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.black : AppColors.gray400).withValues(
                alpha: 0.1,
              ),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.quickActions,
              style: TextStyle(
                color: isDark ? AppColors.gray300 : AppColors.gray700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                if (onPlaylistPressed != null) ...[
                  _ModernIconButton(
                    icon: Icons.queue_music_rounded,
                    onTap: onPlaylistPressed!,
                    tooltip: l10n.playlist,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (onScanPressed != null) ...[
                  _ModernIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: onScanPressed!,
                    tooltip: l10n.refreshLibrary,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ModernIconButton(
                    icon: Icons.delete_sweep_rounded,
                    onTap: () => _showClearLibraryDialog(context, isDark),
                    tooltip: l10n.clearLibrary,
                    isDark: isDark,
                    isDestructive: true,
                  ),
                ],
                if (onSettingsPressed != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _ModernIconButton(
                    icon: Icons.settings_rounded,
                    onTap: onSettingsPressed!,
                    tooltip: l10n.settings,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }
  }
}

class _HeaderButton extends StatefulWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? (widget.isDark
                        ? AppColors.gray800
                        : AppColors.accent.withValues(alpha: 0.1))
                    : (widget.isDark ? AppColors.gray900 : AppColors.gray100),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color:
                  _isHovered
                      ? (widget.isDark ? AppColors.gray600 : AppColors.accent)
                      : (widget.isDark ? AppColors.gray800 : AppColors.gray200),
            ),
          ),
          child: Icon(
            widget.icon,
            color:
                _isHovered
                    ? (widget.isDark ? AppColors.white : AppColors.accent)
                    : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
            size: 20,
          ),
        ),
      ),
    );

    return button;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? AppSpacing.md : AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.black : AppColors.gray400).withValues(
              alpha: 0.1,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: VercelTextField(
        hint: l10n.searchHint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color:
                isDark
                    ? AppColors.gray800.withValues(alpha: 0.5)
                    : AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            Icons.search_rounded,
            size: isCompact ? 16 : 18,
            color: isDark ? AppColors.gray400 : AppColors.accent,
          ),
        ),
        isDark: isDark,
        onChanged: (query) {
          context.read<SearchBloc>().add(SearchQueryChanged(query));
        },
      ),
    );
  }
}

/// Sliver version of _MusicList for unified scrolling
class _SliverMusicList extends StatelessWidget {
  const _SliverMusicList({required this.isDark, this.onTrackSelected});

  final bool isDark;
  final void Function(AudioFile file)? onTrackSelected;

  @override
  Widget build(BuildContext context) => BlocBuilder<PlayerBloc, PlayerState>(
    builder:
        (context, playerState) => BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state.isSearching) {
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      isDark ? AppColors.white : AppColors.accent,
                    ),
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (state.results.isEmpty) {
              return SliverFillRemaining(
                child: _EmptyState(hasQuery: state.hasQuery, isDark: isDark),
              );
            }

            final currentTrackPath = playerState.currentAudio?.path;
            final isCompact = MediaQuery.of(context).size.width < 600;

            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? AppSpacing.md : AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final file = state.results[index];
                  final isCurrentlyPlaying = currentTrackPath == file.path;
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
                    child: _MusicTile(
                      audioFile: file,
                      index: index,
                      isDark: isDark,
                      isCurrentlyPlaying: isCurrentlyPlaying,
                      onTap: () => onTrackSelected?.call(file),
                    ),
                  );
                }, childCount: state.results.length),
              ),
            );
          },
        ),
  );
}

class _MusicTile extends StatefulWidget {
  const _MusicTile({
    required this.audioFile,
    required this.index,
    required this.isDark,
    required this.onTap,
    this.isCurrentlyPlaying = false,
  });

  final AudioFile audioFile;
  final int index;
  final bool isDark;
  final bool isCurrentlyPlaying;
  final VoidCallback onTap;

  @override
  State<_MusicTile> createState() => _MusicTileState();
}

class _MusicTileState extends State<_MusicTile> {
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
                  l10n.deleteFile,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ),
            content: Text(
              l10n.deleteMusicConfirm(widget.audioFile.displayTitle),
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
        context.read<FileScannerBloc>().add(
          FileScannerDeleteFile(
            widget.audioFile.id,
            filePath: widget.audioFile.path,
            deleteFromDisk: true,
          ),
        );
        AppToast.info(
          context,
          l10n.musicDeleted(widget.audioFile.displayTitle),
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
        onTap: widget.onTap,
        onLongPress: _showDeleteDialog,
        onSecondaryTap: _showDeleteDialog,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
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
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border:
                isPlaying
                    ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
                    : null,
          ),
          child: Row(
            children: [
              // Index or play icon
              SizedBox(
                width: isCompact ? 28 : 32,
                child:
                    isPlaying
                        ? Icon(
                          Icons.equalizer_rounded,
                          color: AppColors.accent,
                          size: isCompact ? 18 : 20,
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
              // Album art
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
              // Title and artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: widget.audioFile.displayTitle,
                      child: Text(
                        widget.audioFile.displayTitle,
                        style: TextStyle(
                          color:
                              isPlaying
                                  ? AppColors.accent
                                  : _isHovered
                                  ? (isDark
                                      ? AppColors.white
                                      : AppColors.accent)
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
              // Duration and delete button
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
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
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
  const _EmptyState({required this.isDark, this.hasQuery = false});

  final bool isDark;
  final bool hasQuery;

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
              hasQuery ? Icons.search_off_rounded : Icons.library_music_rounded,
              color: isDark ? AppColors.gray500 : AppColors.accent,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            hasQuery ? l10n.noResults : l10n.emptyLibrary,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasQuery ? l10n.tryOtherKeywords : l10n.emptyLibraryHint,
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

// Modern action card for mobile layout
class _ModernActionCard extends StatefulWidget {
  const _ModernActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    required this.color,
    this.isDestructive = false,
    this.isFullWidth = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final Color color;
  final bool isDestructive;
  final bool isFullWidth;

  @override
  State<_ModernActionCard> createState() => _ModernActionCardState();
}

class _ModernActionCardState extends State<_ModernActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _isPressed = true),
    onTapUp: (_) => setState(() => _isPressed = false),
    onTapCancel: () => setState(() => _isPressed = false),
    onTap: widget.onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: widget.isFullWidth ? double.infinity : null,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient:
            _isPressed
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withValues(alpha: 0.2),
                    widget.color.withValues(alpha: 0.1),
                  ],
                )
                : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      widget.isDark
                          ? [AppColors.gray900, AppColors.gray800]
                          : [AppColors.white, AppColors.gray50],
                ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color:
              _isPressed
                  ? widget.color
                  : (widget.isDark ? AppColors.gray700 : AppColors.gray200),
          width: _isPressed ? 2 : 1,
        ),
        boxShadow: [
          if (_isPressed)
            BoxShadow(
              color: widget.color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: (widget.isDark ? AppColors.black : AppColors.gray400)
                  .withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  _isPressed
                      ? widget.color.withValues(alpha: 0.2)
                      : (widget.isDark ? AppColors.gray800 : AppColors.gray100),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              widget.icon,
              color:
                  _isPressed
                      ? widget.color
                      : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        _isPressed
                            ? widget.color
                            : (widget.isDark
                                ? AppColors.white
                                : AppColors.black),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        widget.isDark ? AppColors.gray500 : AppColors.gray600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Modern icon button
class _ModernIconButton extends StatefulWidget {
  const _ModernIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.tooltip,
    this.isDestructive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final String? tooltip;
  final bool isDestructive;

  @override
  State<_ModernIconButton> createState() => _ModernIconButtonState();
}

class _ModernIconButtonState extends State<_ModernIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? AppColors.error : AppColors.accent;

    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? color.withValues(alpha: 0.1)
                    : (widget.isDark ? AppColors.gray800 : AppColors.gray100),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color:
                  _isHovered
                      ? color
                      : (widget.isDark ? AppColors.gray700 : AppColors.gray300),
            ),
          ),
          child: Icon(
            widget.icon,
            color:
                _isHovered
                    ? color
                    : (widget.isDark ? AppColors.gray400 : AppColors.gray600),
            size: 20,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip, child: button);
    }
    return button;
  }
}
