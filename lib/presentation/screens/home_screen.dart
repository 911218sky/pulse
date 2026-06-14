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
import 'package:pulse/presentation/widgets/common/app_confirm_dialog.dart';
import 'package:pulse/presentation/widgets/common/app_toast.dart';
import 'package:pulse/presentation/widgets/common/vercel_text_field.dart';
import 'package:pulse/presentation/widgets/playing_indicator.dart';

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
    final isCompact = MediaQuery.of(context).size.width < 600;

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
            physics: const BouncingScrollPhysics(),
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
              SliverToBoxAdapter(
                child: SizedBox(
                  height: isCompact ? AppSpacing.sm : AppSpacing.md,
                ),
              ),
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

    AppConfirmDialog.show(
      context,
      title: l10n.clearLibrary,
      message: l10n.clearLibraryConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    ).then((confirmed) {
      if (confirmed && context.mounted) {
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    AppColors.black,
                    AppColors.gray900,
                    AppColors.accentDark.withValues(alpha: 0.18),
                    AppColors.black,
                  ]
                  : [
                    AppColors.white,
                    AppColors.gray50,
                    AppColors.accentLight.withValues(alpha: 0.14),
                    AppColors.white,
                  ],
          stops: const [0.0, 0.48, 0.78, 1.0],
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
            _buildHeroSection(context, l10n, isCompact),
            SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),
            _buildActionSection(context, l10n, isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isCompact,
  ) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
    decoration: BoxDecoration(
      color:
          isDark
              ? AppColors.gray900.withValues(alpha: 0.72)
              : AppColors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      border: Border.all(
        color:
            isDark ? AppColors.gray800 : AppColors.white.withValues(alpha: 0.9),
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? AppColors.black : AppColors.accent).withValues(
            alpha: isDark ? 0.26 : 0.08,
          ),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: -24,
          top: -28,
          child: Container(
            width: isCompact ? 96 : 140,
            height: isCompact ? 96 : 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.08),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.32),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.graphic_eq_rounded,
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
                          fontSize: isCompact ? 30 : 40,
                          height: 0.98,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.exploreYourMusic,
                        style: TextStyle(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontSize: isCompact ? 14 : 16,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: isCompact ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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
            if (!isCompact) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.quickActions,
                style: TextStyle(
                  color: isDark ? AppColors.gray500 : AppColors.gray500,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );

  Widget _buildActionSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isCompact,
  ) {
    if (isCompact) {
      return _MobileActionDock(
        isDark: isDark,
        onScanPressed: onScanPressed,
        onPlaylistPressed: onPlaylistPressed,
        onClearPressed:
            onScanPressed == null
                ? null
                : () => _showClearLibraryDialog(context, isDark),
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
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.quickActions,
                  style: TextStyle(
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
              ],
            ),
          ],
        ),
      );
    }
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

class _MobileActionDock extends StatelessWidget {
  const _MobileActionDock({
    required this.isDark,
    this.onScanPressed,
    this.onPlaylistPressed,
    this.onClearPressed,
  });

  final bool isDark;
  final VoidCallback? onScanPressed;
  final VoidCallback? onPlaylistPressed;
  final VoidCallback? onClearPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.black.withValues(alpha: 0.28)
                : AppColors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isDark ? AppColors.gray800 : AppColors.gray200,
        ),
      ),
      child: Column(
        children: [
          if (onScanPressed != null)
            _MobileActionButton(
              icon: Icons.radar_rounded,
              label: l10n.scanMusic,
              description: l10n.scanNewMusic,
              onTap: onScanPressed!,
              isDark: isDark,
              isPrimary: true,
            ),
          if (onPlaylistPressed != null || onClearPressed != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (onPlaylistPressed != null)
                  Expanded(
                    child: _MobileActionButton(
                      icon: Icons.queue_music_rounded,
                      label: l10n.playlist,
                      description: l10n.managePlaylist,
                      onTap: onPlaylistPressed!,
                      isDark: isDark,
                    ),
                  ),
                if (onPlaylistPressed != null && onClearPressed != null)
                  const SizedBox(width: AppSpacing.sm),
                if (onClearPressed != null)
                  Expanded(
                    child: _MobileActionButton(
                      icon: Icons.delete_sweep_rounded,
                      label: l10n.clearLibrary,
                      description: l10n.clearLibraryDesc,
                      onTap: onClearPressed!,
                      isDark: isDark,
                      isDestructive: true,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileActionButton extends StatefulWidget {
  const _MobileActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    required this.isDark,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isDark;
  final bool isPrimary;
  final bool isDestructive;

  @override
  State<_MobileActionButton> createState() => _MobileActionButtonState();
}

class _MobileActionButtonState extends State<_MobileActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? AppColors.error : AppColors.accent;
    final foreground =
        widget.isPrimary
            ? AppColors.white
            : widget.isDestructive
            ? AppColors.error
            : (widget.isDark ? AppColors.white : AppColors.black);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(
          widget.isPrimary ? AppSpacing.md : AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient:
              widget.isPrimary
                  ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.accentDark],
                  )
                  : null,
          color:
              widget.isPrimary
                  ? null
                  : _isPressed
                  ? color.withValues(alpha: 0.12)
                  : (widget.isDark ? AppColors.gray900 : AppColors.white),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color:
                widget.isPrimary
                    ? AppColors.accentLight.withValues(alpha: 0.6)
                    : _isPressed
                    ? color
                    : (widget.isDark ? AppColors.gray800 : AppColors.gray200),
          ),
          boxShadow: [
            if (widget.isPrimary)
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: widget.isPrimary ? 44 : 36,
              height: widget.isPrimary ? 44 : 36,
              decoration: BoxDecoration(
                color:
                    widget.isPrimary
                        ? AppColors.white.withValues(alpha: 0.18)
                        : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                widget.icon,
                color: widget.isPrimary ? AppColors.white : color,
                size: widget.isPrimary ? 23 : 19,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: widget.isPrimary ? 15 : 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          widget.isPrimary
                              ? AppColors.white.withValues(alpha: 0.72)
                              : (widget.isDark
                                  ? AppColors.gray500
                                  : AppColors.gray600),
                      fontSize: widget.isPrimary ? 12 : 11,
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
                hasScrollBody: false,
                child: _EmptyState(hasQuery: state.hasQuery, isDark: isDark),
              );
            }

            final currentTrackPath = playerState.currentAudio?.path;
            final isCompact = MediaQuery.of(context).size.width < 600;

            return SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: _LibrarySectionHeader(
                    count: state.results.length,
                    hasQuery: state.hasQuery,
                    isDark: isDark,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? AppSpacing.md : AppSpacing.xl,
                    AppSpacing.sm,
                    isCompact ? AppSpacing.md : AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final file = state.results[index];
                      final isCurrentlyPlaying = currentTrackPath == file.path;
                      final isActuallyPlaying =
                          isCurrentlyPlaying && playerState.isPlaying;
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark
                                      ? AppColors.black
                                      : AppColors.gray400)
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
                          isActuallyPlaying: isActuallyPlaying,
                          onTap: () => onTrackSelected?.call(file),
                        ),
                      );
                    }, childCount: state.results.length),
                  ),
                ),
              ],
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
    this.isActuallyPlaying = false,
  });

  final AudioFile audioFile;
  final int index;
  final bool isDark;
  final bool isCurrentlyPlaying;
  final bool isActuallyPlaying;
  final VoidCallback onTap;

  @override
  State<_MusicTile> createState() => _MusicTileState();
}

class _LibrarySectionHeader extends StatelessWidget {
  const _LibrarySectionHeader({
    required this.count,
    required this.hasQuery,
    required this.isDark,
  });

  final int count;
  final bool hasQuery;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.md : AppSpacing.xl,
        AppSpacing.md,
        isCompact ? AppSpacing.md : AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasQuery ? l10n.results : l10n.musicLibrary,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.black,
                fontSize: isCompact ? 16 : 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? AppColors.gray900
                      : AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isDark ? AppColors.gray800 : AppColors.gray200,
              ),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: isDark ? AppColors.gray300 : AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackLeading extends StatelessWidget {
  const _TrackLeading({
    required this.index,
    required this.isDark,
    required this.isHovered,
    required this.isPlaying,
    required this.isActuallyPlaying,
    required this.isCompact,
  });

  final int index;
  final bool isDark;
  final bool isHovered;
  final bool isPlaying;
  final bool isActuallyPlaying;
  final bool isCompact;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: isCompact ? 24 : 32,
    child:
        isPlaying
            ? PlayingIndicator(
              color: AppColors.accent,
              size: isCompact ? 18 : 20,
              isAnimating: isActuallyPlaying,
            )
            : isHovered
            ? Icon(
              Icons.play_arrow_rounded,
              color: isDark ? AppColors.white : AppColors.accent,
              size: isCompact ? 18 : 20,
            )
            : Text(
              '${index + 1}',
              style: TextStyle(
                color: isDark ? AppColors.gray500 : AppColors.gray400,
                fontSize: isCompact ? 12 : 14,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
  );
}

enum _TrackAction { delete }

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
          padding: EdgeInsets.fromLTRB(
            isCompact ? AppSpacing.sm : AppSpacing.md,
            isCompact ? AppSpacing.sm : AppSpacing.md,
            isCompact ? AppSpacing.sm : AppSpacing.md,
            isCompact ? AppSpacing.sm : AppSpacing.md,
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
              _TrackLeading(
                index: widget.index,
                isDark: isDark,
                isHovered: _isHovered,
                isPlaying: isPlaying,
                isActuallyPlaying: widget.isActuallyPlaying,
                isCompact: isCompact,
              ),
              SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
              Container(
                width: isCompact ? 44 : 52,
                height: isCompact ? 44 : 52,
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
                          height: 1.18,
                          fontWeight:
                              isPlaying ? FontWeight.w700 : FontWeight.w600,
                        ),
                        maxLines: isCompact ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.audioFile.artist ?? l10n.unknownArtist,
                            style: TextStyle(
                              color:
                                  isPlaying
                                      ? AppColors.accent.withValues(alpha: 0.74)
                                      : (isDark
                                          ? AppColors.gray500
                                          : AppColors.gray600),
                              fontSize: isCompact ? 11 : 13,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompact &&
                            widget.audioFile.duration > Duration.zero) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            TimeParser.formatDuration(
                              widget.audioFile.duration,
                            ),
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.gray600
                                      : AppColors.gray500,
                              fontSize: 11,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ],
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
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color:
                      _isHovered
                          ? AppColors.error
                          : (isDark ? AppColors.gray600 : AppColors.gray400),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: _showDeleteDialog,
                  tooltip: l10n.removeFromLibrary,
                ),
              ] else ...[
                const SizedBox(width: AppSpacing.xs),
                PopupMenuButton<_TrackAction>(
                  color: isDark ? AppColors.gray900 : AppColors.white,
                  tooltip: l10n.removeFromLibrary,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: isDark ? AppColors.gray500 : AppColors.gray500,
                    size: 20,
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _TrackAction.delete:
                        _showDeleteDialog();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: _TrackAction.delete,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                l10n.removeFromLibrary,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
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
