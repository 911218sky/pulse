import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';
import 'package:pulse/presentation/widgets/common/vercel_text_field.dart';

/// Screen for managing playlists
class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key, this.onPlaylistSelected, this.onBack});

  final void Function(Playlist playlist)? onPlaylistSelected;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.black,
    body: SafeArea(
      child: Column(
        children: [
          _Header(onBack: onBack),
          Expanded(
            child: BlocBuilder<PlaylistBloc, PlaylistState>(
              builder: (context, state) {
                if (state.status == PlaylistStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  );
                }

                if (state.playlists.isEmpty) {
                  return const _EmptyState();
                }

                return _PlaylistList(
                  playlists: state.playlists,
                  currentPlaylistId: state.currentPlaylist?.id,
                  onPlaylistSelected: onPlaylistSelected,
                );
              },
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      onPressed: () => _showCreatePlaylistDialog(context),
      child: const Icon(Icons.add_rounded),
    ),
  );

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final name = await _CreatePlaylistDialog.show(context);
    if (name != null && name.isNotEmpty && context.mounted) {
      context.read<PlaylistBloc>().add(PlaylistCreate(name));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.white,
              onPressed: onBack,
            ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            l10n.playlist,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistList extends StatelessWidget {
  const _PlaylistList({
    required this.playlists,
    this.currentPlaylistId,
    this.onPlaylistSelected,
  });

  final List<Playlist> playlists;
  final String? currentPlaylistId;
  final void Function(Playlist playlist)? onPlaylistSelected;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: playlists.length,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    itemBuilder: (context, index) {
      final playlist = playlists[index];
      return _PlaylistCard(
        playlist: playlist,
        isSelected: playlist.id == currentPlaylistId,
        onTap: () => onPlaylistSelected?.call(playlist),
        onDelete: () => _confirmDelete(context, playlist),
        onRename: () => _showRenameDialog(context, playlist),
      );
    },
  );

  Future<void> _confirmDelete(BuildContext context, Playlist playlist) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.gray900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              side: const BorderSide(color: AppColors.gray700),
            ),
            title: Text(
              l10n.deletePlaylist,
              style: const TextStyle(color: AppColors.white),
            ),
            content: Text(
              l10n.deletePlaylistConfirm(playlist.name),
              style: const TextStyle(color: AppColors.gray400),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<PlaylistBloc>().add(PlaylistDelete(playlist.id));
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

class _PlaylistCard extends StatefulWidget {
  const _PlaylistCard({
    required this.playlist,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.onRename,
  });

  final Playlist playlist;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  @override
  State<_PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<_PlaylistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color:
                widget.isSelected
                    ? AppColors.gray800
                    : _isHovered
                    ? AppColors.gray900
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color:
                  widget.isSelected
                      ? AppColors.white
                      : _isHovered
                      ? AppColors.gray700
                      : AppColors.gray800,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gray800,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.queue_music_rounded,
                  color: AppColors.gray500,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.playlist.name,
                      style: TextStyle(
                        color:
                            widget.isSelected
                                ? AppColors.white
                                : AppColors.gray200,
                        fontSize: 16,
                        fontWeight:
                            widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.songsCount(widget.playlist.fileCount),
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isHovered) ...[
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  color: AppColors.gray400,
                  iconSize: 20,
                  onPressed: widget.onRename,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  color: AppColors.gray400,
                  iconSize: 20,
                  onPressed: widget.onDelete,
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.playlist_add_rounded,
            color: AppColors.gray600,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.noPlaylists,
            style: const TextStyle(color: AppColors.gray500, fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.noPlaylistsHint,
            style: const TextStyle(color: AppColors.gray600, fontSize: 14),
          ),
        ],
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
    return Dialog(
      backgroundColor: AppColors.gray900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.gray700),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createPlaylist,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            VercelTextField(
              controller: _controller,
              label: l10n.playlistName,
              hint: l10n.playlistNameHint,
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VercelButton(
                  label: l10n.cancel,
                  variant: VercelButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.md),
                VercelButton(label: l10n.create, onPressed: _submit),
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
    return Dialog(
      backgroundColor: AppColors.gray900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.gray700),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.renamePlaylist,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            VercelTextField(
              controller: _controller,
              label: l10n.playlistName,
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                VercelButton(
                  label: l10n.cancel,
                  variant: VercelButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.md),
                VercelButton(label: l10n.save, onPressed: _submit),
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
