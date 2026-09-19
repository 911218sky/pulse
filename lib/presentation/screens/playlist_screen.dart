import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';
import 'package:pulse/presentation/widgets/common/app_confirm_dialog.dart';
import 'package:pulse/presentation/widgets/common/app_empty_state.dart';
import 'package:pulse/presentation/widgets/common/app_screen_header.dart';
import 'package:pulse/presentation/widgets/common/app_toast.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';
import 'package:pulse/presentation/widgets/common/vercel_card.dart';
import 'package:pulse/presentation/widgets/common/vercel_text_field.dart';
import 'package:pulse/presentation/widgets/playing_indicator.dart';

/// Screen for managing playlists
class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key, this.onPlaylistSelected, this.onBack});

  final void Function(Playlist playlist)? onPlaylistSelected;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final palette = context.appPalette;
    final l10n = AppLocalizations.of(context);

    return BlocListener<PlaylistBloc, PlaylistState>(
      listenWhen:
          (previous, current) =>
              current.status == PlaylistStatus.playlistDeleted,
      listener: (context, state) {
        // Stop player when current playlist is deleted
        context.read<PlayerBloc>().add(const PlayerStop());
      },
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          child: Column(
            children: [
              AppScreenHeader(
                title: l10n.playlist,
                subtitle: l10n.playlistDesc,
                isDark: isDark,
                onBack: onBack,
                trailing: AppHeaderActionButton(
                  icon: Icons.add_rounded,
                  tooltip: l10n.createPlaylist,
                  onPressed: () => _showCreatePlaylistDialog(context),
                ),
              ),
              Expanded(
                child: BlocBuilder<PlaylistBloc, PlaylistState>(
                  builder: (context, state) {
                    if (state.status == PlaylistStatus.loading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            isDark ? AppColors.white : AppColors.accent,
                          ),
                          strokeWidth: 2,
                        ),
                      );
                    }

                    if (state.playlists.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.playlist_add_rounded,
                        title: l10n.noPlaylists,
                        message: l10n.noPlaylistsHint,
                        actionLabel: l10n.createPlaylist,
                        actionIcon: Icons.add_rounded,
                        onAction: () => _showCreatePlaylistDialog(context),
                      );
                    }

                    return _PlaylistList(
                      playlists: state.playlists,
                      currentPlaylistId: state.currentPlaylist?.id,
                      onPlaylistSelected: onPlaylistSelected,
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final name = await _CreatePlaylistDialog.show(context);
    if (name != null && name.isNotEmpty && context.mounted) {
      context.read<PlaylistBloc>().add(PlaylistCreate(name));
    }
  }
}

class _PlaylistList extends StatelessWidget {
  const _PlaylistList({
    required this.playlists,
    required this.isDark,
    this.currentPlaylistId,
    this.onPlaylistSelected,
  });

  final List<Playlist> playlists;
  final String? currentPlaylistId;
  final void Function(Playlist playlist)? onPlaylistSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen:
          (previous, current) =>
              previous.currentAudio?.path != current.currentAudio?.path ||
              previous.isPlaying != current.isPlaying,
      builder: (context, playerState) {
        final currentTrackPath = playerState.currentAudio?.path;

        return ListView.builder(
          itemCount: playlists.length,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.md : AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            final isPlayingFromPlaylist =
                currentTrackPath != null &&
                playlist.containsPath(currentTrackPath);
            final isActuallyPlaying =
                isPlayingFromPlaylist && playerState.isPlaying;

            return VercelListTile(
              dense: true,
              style: VercelListTileStyle.inset,
              isSelected: isPlayingFromPlaylist,
              showBottomDivider: index < playlists.length - 1,
              onTap: () {
                onPlaylistSelected?.call(playlist);
                context.push('/playlist/${playlist.id}');
              },
              onLongPress: () => _showPlaylistOptions(context, playlist),
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.mdSm,
              ),
              leading: _PlaylistArt(
                isPlaying: isPlayingFromPlaylist,
                isActuallyPlaying: isActuallyPlaying,
              ),
              title: Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge(
                  isPlayingFromPlaylist
                      ? AppColors.accentLight
                      : context.appPalette.primaryText,
                ).copyWith(
                  fontWeight:
                      isPlayingFromPlaylist ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              subtitle: Text(l10n.songsCount(playlist.fileCount)),
              trailing: IconButton(
                icon: const Icon(Icons.more_horiz),
                color: context.appPalette.mutedText,
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                tooltip: l10n.deletePlaylist,
                onPressed: () => _showPlaylistOptions(context, playlist),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showPlaylistOptions(
    BuildContext context,
    Playlist playlist,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = context.appPalette;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.elevatedSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: Icon(Icons.edit_rounded, color: palette.mutedText),
                  title: Text(
                    l10n.renamePlaylist,
                    style: AppTypography.labelLarge(palette.primaryText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showRenameDialog(context, playlist);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_rounded,
                    color: AppColors.error,
                  ),
                  title: Text(
                    l10n.deletePlaylist,
                    style: AppTypography.labelLarge(AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context, playlist);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Playlist playlist) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.deletePlaylist,
      message: l10n.deletePlaylistConfirm(playlist.name),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );

    if (confirmed && context.mounted) {
      context.read<PlaylistBloc>().add(PlaylistDelete(playlist.id));
      AppToast.success(context, AppLocalizations.of(context).playlistDeleted);
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    Playlist playlist,
  ) async {
    final newName = await _RenamePlaylistDialog.show(context, playlist.name);
    if (newName != null && newName.isNotEmpty && context.mounted) {
      context.read<PlaylistBloc>().add(
        PlaylistRename(playlistId: playlist.id, newName: newName),
      );
    }
  }
}

class _PlaylistArt extends StatelessWidget {
  const _PlaylistArt({
    required this.isPlaying,
    required this.isActuallyPlaying,
  });

  final bool isPlaying;
  final bool isActuallyPlaying;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    const size = AppSpacing.trackArtSize;
    final radius = BorderRadius.circular(AppSpacing.radiusArt);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.interactive,
          borderRadius: radius,
        ),
        child: Center(
          child:
              isPlaying
                  ? PlayingIndicator(
                    color: AppColors.accent,
                    size: 16,
                    isAnimating: isActuallyPlaying,
                  )
                  : Icon(
                    Icons.queue_music_rounded,
                    color: palette.mutedText,
                    size: 22,
                  ),
        ),
      ),
    );
  }
}

class _CreatePlaylistDialog extends StatefulWidget {
  const _CreatePlaylistDialog();

  static Future<String?> show(BuildContext context) => showDialog<String>(
    context: context,
    builder: (context) => const _CreatePlaylistDialog(),
  );

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: isDark ? AppColors.gray800 : AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  child: Text(
                    l10n.createPlaylist,
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            VercelTextField(
              controller: _controller,
              label: l10n.playlistName,
              hint: l10n.playlistNameHint,
              autofocus: true,
              isDark: isDark,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VercelButton(
                  label: l10n.cancel,
                  variant: VercelButtonVariant.secondary,
                  isDark: isDark,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.md),
                VercelButton(
                  label: l10n.create,
                  isDark: isDark,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    Navigator.pop(context, _controller.text.trim());
  }
}

class _RenamePlaylistDialog extends StatefulWidget {
  const _RenamePlaylistDialog({required this.currentName});

  final String currentName;

  static Future<String?> show(BuildContext context, String currentName) =>
      showDialog<String>(
        context: context,
        builder: (context) => _RenamePlaylistDialog(currentName: currentName),
      );

  @override
  State<_RenamePlaylistDialog> createState() => _RenamePlaylistDialogState();
}

class _RenamePlaylistDialogState extends State<_RenamePlaylistDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: isDark ? AppColors.gray800 : AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.gray800 : AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.renamePlaylist,
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            VercelTextField(
              controller: _controller,
              label: l10n.playlistName,
              autofocus: true,
              isDark: isDark,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VercelButton(
                  label: l10n.cancel,
                  variant: VercelButtonVariant.secondary,
                  isDark: isDark,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.md),
                VercelButton(
                  label: l10n.save,
                  isDark: isDark,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    Navigator.pop(context, _controller.text.trim());
  }
}
