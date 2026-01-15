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
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/bloc/search/search_event.dart';
import 'package:pulse/presentation/bloc/search/search_state.dart';
import 'package:pulse/presentation/widgets/common/vercel_text_field.dart';

/// Home screen showing the music library
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onTrackSelected,
    this.onSettingsPressed,
    this.onScanPressed,
  });

  final void Function(AudioFile file)? onTrackSelected;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onScanPressed;

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

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onSettingsPressed: widget.onSettingsPressed,
              onScanPressed: widget.onScanPressed,
              isDark: isDark,
            ),
            _SearchBar(isDark: isDark),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _MusicList(
                onTrackSelected: widget.onTrackSelected,
                isDark: isDark,
              ),
            ),
          ],
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
  });

  final bool isDark;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onScanPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [AppColors.gray700, AppColors.gray900]
                        : [AppColors.accent, AppColors.accentDark],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.library_music_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            l10n.musicLibrary,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.black,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (onScanPressed != null)
            _HeaderButton(
              icon: Icons.refresh_rounded,
              onTap: onScanPressed!,
              tooltip: l10n.scanMusic,
              isDark: isDark,
            ),
          if (onSettingsPressed != null) ...[
            const SizedBox(width: AppSpacing.sm),
            _HeaderButton(
              icon: Icons.settings_rounded,
              onTap: onSettingsPressed!,
              tooltip: l10n.settings,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderButton extends StatefulWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final String? tooltip;

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

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip, child: button);
    }
    return button;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: VercelTextField(
        hint: l10n.searchHint,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: isDark ? AppColors.gray400 : AppColors.gray500,
        ),
        isDark: isDark,
        onChanged: (query) {
          context.read<SearchBloc>().add(SearchQueryChanged(query));
        },
      ),
    );
  }
}

class _MusicList extends StatelessWidget {
  const _MusicList({required this.isDark, this.onTrackSelected});

  final bool isDark;
  final void Function(AudioFile file)? onTrackSelected;

  @override
  Widget build(BuildContext context) => BlocBuilder<SearchBloc, SearchState>(
    builder: (context, state) {
      if (state.isSearching) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
              isDark ? AppColors.white : AppColors.accent,
            ),
            strokeWidth: 2,
          ),
        );
      }

      if (state.results.isEmpty) {
        return _EmptyState(hasQuery: state.hasQuery, isDark: isDark);
      }

      return ListView.builder(
        itemCount: state.results.length,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemBuilder: (context, index) {
          final file = state.results[index];
          return _MusicTile(
            audioFile: file,
            index: index,
            isDark: isDark,
            onTap: () => onTrackSelected?.call(file),
          );
        },
      );
    },
  );
}

class _MusicTile extends StatefulWidget {
  const _MusicTile({
    required this.audioFile,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

  final AudioFile audioFile;
  final int index;
  final bool isDark;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.musicDeleted(widget.audioFile.displayTitle)),
            backgroundColor: isDark ? AppColors.gray800 : AppColors.gray700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;

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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? (isDark
                        ? AppColors.gray900
                        : AppColors.accent.withValues(alpha: 0.05))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              // Index or play icon
              SizedBox(
                width: 32,
                child:
                    _isHovered
                        ? Icon(
                          Icons.play_arrow_rounded,
                          color: isDark ? AppColors.white : AppColors.accent,
                          size: 20,
                        )
                        : Text(
                          '${widget.index + 1}',
                          style: TextStyle(
                            color:
                                isDark ? AppColors.gray500 : AppColors.gray400,
                            fontSize: 14,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Album art
              Container(
                width: 48,
                height: 48,
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
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: isDark ? AppColors.gray600 : AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Title and artist
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
                        fontSize: 15,
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
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Duration
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
              // Delete button (always visible)
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color:
                    _isHovered
                        ? AppColors.error
                        : (isDark ? AppColors.gray600 : AppColors.gray400),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
