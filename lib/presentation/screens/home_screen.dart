import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';
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
import 'package:pulse/presentation/widgets/common/app_empty_state.dart';
import 'package:pulse/presentation/widgets/common/app_toast.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';
import 'package:pulse/presentation/widgets/common/vercel_card.dart';
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
    final palette = context.appPalette;
    final isDark = context.isDarkMode;
    final isCompact = MediaQuery.of(context).size.width < 600;

    return MultiBlocListener(
      listeners: [
        BlocListener<FileScannerBloc, FileScannerState>(
          listenWhen:
              (previous, current) =>
                  previous.folders != current.folders ||
                  previous.libraryFiles != current.libraryFiles,
          listener: (context, state) {
            context.read<SearchBloc>().add(SearchSourceUpdated(state.allFiles));
          },
        ),
        BlocListener<FileScannerBloc, FileScannerState>(
          listenWhen:
              (previous, current) =>
                  previous.status != current.status &&
                  (current.status == FileScannerStatus.fileDeleted ||
                      current.status == FileScannerStatus.deleteFailed ||
                      current.status == FileScannerStatus.deleteCancelled),
          listener: (context, state) {
            final l10n = AppLocalizations.of(context);
            switch (state.status) {
              case FileScannerStatus.fileDeleted:
                final title = state.lastDeletedTitle;
                AppToast.success(
                  context,
                  title != null ? l10n.musicDeleted(title) : l10n.deleteFile,
                );
              case FileScannerStatus.deleteFailed:
                AppToast.error(context, l10n.musicDeleteFailed);
              case FileScannerStatus.deleteCancelled:
                AppToast.info(context, l10n.musicDeleteCancelled);
              case FileScannerStatus.initial:
              case FileScannerStatus.loading:
              case FileScannerStatus.scanning:
              case FileScannerStatus.completed:
              case FileScannerStatus.error:
                break;
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HomeHeader(
                  isDark: isDark,
                  isCompact: isCompact,
                  onSettingsPressed: widget.onSettingsPressed,
                  onScanPressed: widget.onScanPressed,
                  onPlaylistPressed: widget.onPlaylistPressed,
                ),
              ),
              SliverToBoxAdapter(
                child: _SearchBar(isDark: isDark, isCompact: isCompact),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: isCompact ? AppSpacing.sm : AppSpacing.md,
                ),
              ),
              _SliverMusicList(
                isDark: isDark,
                onTrackSelected: widget.onTrackSelected,
                onScanPressed: widget.onScanPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.isDark,
    required this.isCompact,
    this.onSettingsPressed,
    this.onScanPressed,
    this.onPlaylistPressed,
  });

  final bool isDark;
  final bool isCompact;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onScanPressed;
  final VoidCallback? onPlaylistPressed;

  static Future<void> _clearLibrary(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.clearLibrary,
      message: l10n.clearLibraryConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (!confirmed || !context.mounted) return;
    context.read<FileScannerBloc>().add(const FileScannerClearLibrary());
    context.read<SearchBloc>().add(const SearchSourceUpdated([]));
    AppToast.success(context, l10n.libraryCleared);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.appPalette;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.md : AppSpacing.xl,
        isCompact ? AppSpacing.md : AppSpacing.lg,
        isCompact ? AppSpacing.md : AppSpacing.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.musicLibrary,
                      style: AppTypography.displaySmall(
                        palette.primaryText,
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.exploreYourMusic,
                      style: AppTypography.bodyMedium(palette.secondaryText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onSettingsPressed != null)
                _ChromeIconButton(
                  icon: Icons.settings_outlined,
                  tooltip: l10n.settings,
                  onTap: onSettingsPressed,
                ),
              if (onScanPressed != null) ...[
                const SizedBox(width: 4),
                Material(
                  color: Colors.transparent,
                  child: PopupMenuButton<_HomeMenuAction>(
                    tooltip: l10n.clearLibrary,
                    padding: EdgeInsets.zero,
                    color: palette.elevatedSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      side: BorderSide(color: palette.subtleBorder),
                    ),
                    onSelected: (action) {
                      if (action == _HomeMenuAction.clearLibrary) {
                        _clearLibrary(context);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: _HomeMenuAction.clearLibrary,
                            child: Text(
                              l10n.clearLibrary,
                              style: AppTypography.labelLarge(AppColors.error),
                            ),
                          ),
                        ],
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: palette.secondaryText,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (onScanPressed != null)
                Expanded(
                  child: VercelButton(
                    label: l10n.scanMusic,
                    icon: Icons.radar_rounded,
                    onPressed: onScanPressed,
                    fullWidth: true,
                  ),
                ),
              if (onScanPressed != null && onPlaylistPressed != null)
                const SizedBox(width: AppSpacing.sm),
              if (onPlaylistPressed != null)
                Expanded(
                  child: VercelButton(
                    label: l10n.playlist,
                    icon: Icons.queue_music_rounded,
                    onPressed: onPlaylistPressed,
                    variant: VercelButtonVariant.secondary,
                    fullWidth: true,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, thickness: 1, color: palette.divider),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

enum _HomeMenuAction { clearLibrary }

class _ChromeIconButton extends StatelessWidget {
  const _ChromeIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: palette.secondaryText, size: 22),
        ),
      ),
    );

    return Tooltip(message: tooltip, child: button);
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.isDark, required this.isCompact});

  final bool isDark;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.appPalette;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppSpacing.md : AppSpacing.xl,
      ),
      child: VercelTextField(
        hint: l10n.searchHint,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 18,
          color: palette.mutedText,
        ),
        isDark: isDark,
        onChanged: (query) {
          context.read<SearchBloc>().add(SearchQueryChanged(query));
        },
      ),
    );
  }
}

class _SliverMusicList extends StatelessWidget {
  const _SliverMusicList({
    required this.isDark,
    this.onTrackSelected,
    this.onScanPressed,
  });

  final bool isDark;
  final void Function(AudioFile file)? onTrackSelected;
  final VoidCallback? onScanPressed;

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
              final l10n = AppLocalizations.of(context);
              return SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon:
                      state.hasQuery
                          ? Icons.search_off_rounded
                          : Icons.library_music_outlined,
                  title: state.hasQuery ? l10n.noResults : l10n.emptyLibrary,
                  message:
                      state.hasQuery
                          ? l10n.tryOtherKeywords
                          : l10n.emptyLibraryHint,
                  actionLabel:
                      !state.hasQuery && onScanPressed != null
                          ? l10n.scanMusic
                          : null,
                  actionIcon:
                      !state.hasQuery && onScanPressed != null
                          ? Icons.radar_rounded
                          : null,
                  onAction:
                      !state.hasQuery && onScanPressed != null
                          ? onScanPressed
                          : null,
                ),
              );
            }

            final currentTrackPath = playerState.currentAudio?.path;
            final isCompact = MediaQuery.of(context).size.width < 600;
            final palette = context.appPalette;

            return SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? AppSpacing.md : AppSpacing.xl,
                      AppSpacing.sm,
                      isCompact ? AppSpacing.md : AppSpacing.xl,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      state.hasQuery
                          ? '${AppLocalizations.of(context).results} · ${state.results.length}'
                          : '${state.results.length}',
                      style: AppTypography.labelSmall(palette.mutedText),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? AppSpacing.md : AppSpacing.xl,
                    0,
                    isCompact ? AppSpacing.md : AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final file = state.results[index];
                      final isCurrentlyPlaying = currentTrackPath == file.path;
                      final isActuallyPlaying =
                          isCurrentlyPlaying && playerState.isPlaying;
                      final isLast = index == state.results.length - 1;
                      return _MusicTile(
                        audioFile: file,
                        isCurrentlyPlaying: isCurrentlyPlaying,
                        isActuallyPlaying: isActuallyPlaying,
                        showDivider: !isLast,
                        onTap: () => onTrackSelected?.call(file),
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

enum _TrackAction { delete }

class _MusicTile extends StatelessWidget {
  const _MusicTile({
    required this.audioFile,
    required this.onTap,
    this.isCurrentlyPlaying = false,
    this.isActuallyPlaying = false,
    this.showDivider = true,
  });

  final AudioFile audioFile;
  final bool isCurrentlyPlaying;
  final bool isActuallyPlaying;
  final bool showDivider;
  final VoidCallback onTap;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.deleteFile,
      message: l10n.deleteMusicConfirm(audioFile.displayTitle),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (!confirmed || !context.mounted) return;
    context.read<FileScannerBloc>().add(
      FileScannerDeleteFile(
        audioFile.id,
        filePath: audioFile.path,
        deleteFromDisk: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.appPalette;
    final isCompact = MediaQuery.of(context).size.width < 600;
    final hasDuration = audioFile.duration > Duration.zero;
    final durationLabel =
        hasDuration ? TimeParser.formatDuration(audioFile.duration) : null;

    return VercelListTile(
      dense: true,
      style: VercelListTileStyle.inset,
      isSelected: isCurrentlyPlaying,
      showBottomDivider: showDivider,
      onTap: onTap,
      onLongPress: () => _confirmDelete(context),
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.mdSm),
      leading: _TrackArt(
        artworkPath: audioFile.artworkPath,
        isCurrentlyPlaying: isCurrentlyPlaying,
        isActuallyPlaying: isActuallyPlaying,
        palette: palette,
      ),
      title: Text(
        audioFile.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelLarge(
          isCurrentlyPlaying ? AppColors.accentLight : palette.primaryText,
        ).copyWith(
          fontWeight: isCurrentlyPlaying ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        audioFile.artist ?? l10n.unknownArtist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (durationLabel != null) ...[
            Text(
              durationLabel,
              style: AppTypography.timeDisplay(palette.mutedText),
            ),
            const SizedBox(width: 4),
          ],
          if (isCompact)
            SizedBox(
              width: 32,
              height: 32,
              child: PopupMenuButton<_TrackAction>(
                color: palette.elevatedSurface,
                tooltip: l10n.removeFromLibrary,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_horiz,
                  color: palette.mutedText,
                  size: 18,
                ),
                onSelected: (action) {
                  if (action == _TrackAction.delete) {
                    _confirmDelete(context);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: _TrackAction.delete,
                        child: Text(
                          l10n.removeFromLibrary,
                          style: AppTypography.labelLarge(AppColors.error),
                        ),
                      ),
                    ],
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: palette.mutedText,
              iconSize: 18,
              tooltip: l10n.removeFromLibrary,
              visualDensity: VisualDensity.compact,
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
    );
  }
}

class _TrackArt extends StatelessWidget {
  const _TrackArt({
    required this.artworkPath,
    required this.isCurrentlyPlaying,
    required this.isActuallyPlaying,
    required this.palette,
  });

  final String? artworkPath;
  final bool isCurrentlyPlaying;
  final bool isActuallyPlaying;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    const size = AppSpacing.trackArtSize;
    final radius = BorderRadius.circular(AppSpacing.radiusArt);

    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.interactive,
        borderRadius: radius,
      ),
      child: Center(
        child:
            isCurrentlyPlaying
                ? PlayingIndicator(
                  color: AppColors.accent,
                  size: 16,
                  isAnimating: isActuallyPlaying,
                )
                : Icon(
                  Icons.music_note_outlined,
                  color: palette.mutedText,
                  size: 20,
                ),
      ),
    );

    if (artworkPath == null || artworkPath!.isEmpty) {
      return SizedBox(width: size, height: size, child: fallback);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: radius,
            child: Image.file(
              File(artworkPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
          ),
          if (isCurrentlyPlaying)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.45),
                borderRadius: radius,
              ),
              child: Center(
                child: PlayingIndicator(
                  color: AppColors.accentLight,
                  size: 16,
                  isAnimating: isActuallyPlaying,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
