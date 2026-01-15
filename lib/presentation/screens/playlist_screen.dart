import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: onBack, isDark: isDark),
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
                    return _EmptyState(isDark: isDark);
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? AppColors.white : AppColors.accent,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        onPressed: () => _showCreatePlaylistDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppLocalizations.of(context).createPlaylist,
          style: const TextStyle(fontWeight: FontWeight.w600),
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

class _Header extends StatelessWidget {
  const _Header({required this.isDark, this.onBack});

  final VoidCallback? onBack;
  final bool isDark;

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
        child: Row(
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
                    l10n.playlist,
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.black,
                      fontSize: isCompact ? 24 : 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.managePlaylist,
                    style: TextStyle(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      fontSize: isCompact ? 14 : 16,
                      fontWeight: FontWeight.w500,
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

    return ListView.builder(
      itemCount: playlists.length,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppSpacing.md : AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        final playlist = playlists[index];
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
          child: _PlaylistCard(
            playlist: playlist,
            isSelected: playlist.id == currentPlaylistId,
            onTap: () => onPlaylistSelected?.call(playlist),
            onDelete: () => _confirmDelete(context, playlist),
            onRename: () => _showRenameDialog(context, playlist),
            isDark: isDark,
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Playlist playlist) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
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
                Expanded(
                  child: Text(
                    l10n.deletePlaylist,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
            content: Text(
              l10n.deletePlaylistConfirm(playlist.name),
              style: TextStyle(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
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
    required this.isDark,
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
  final bool isDark;

  @override
  State<_PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<_PlaylistCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push('/playlist/${widget.playlist.id}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
          decoration: BoxDecoration(
            gradient:
                widget.isSelected
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          widget.isDark
                              ? [
                                AppColors.accent.withValues(alpha: 0.2),
                                AppColors.accent.withValues(alpha: 0.1),
                              ]
                              : [
                                AppColors.accent.withValues(alpha: 0.1),
                                AppColors.accent.withValues(alpha: 0.05),
                              ],
                    )
                    : _isHovered
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          widget.isDark
                              ? [AppColors.gray900, AppColors.gray800]
                              : [AppColors.gray50, AppColors.white],
                    )
                    : null,
            color:
                !widget.isSelected && !_isHovered
                    ? (widget.isDark ? AppColors.gray900 : AppColors.white)
                    : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color:
                  widget.isSelected
                      ? AppColors.accent
                      : _isHovered
                      ? (widget.isDark ? AppColors.gray700 : AppColors.gray300)
                      : (widget.isDark ? AppColors.gray800 : AppColors.gray200),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isCompact ? 48 : 56,
                height: isCompact ? 48 : 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        widget.isSelected
                            ? [AppColors.accent, AppColors.accentDark]
                            : widget.isDark
                            ? [AppColors.gray800, AppColors.gray900]
                            : [
                              AppColors.accentLight.withValues(alpha: 0.2),
                              AppColors.accent.withValues(alpha: 0.3),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.queue_music_rounded,
                  color:
                      widget.isSelected
                          ? AppColors.white
                          : (widget.isDark
                              ? AppColors.gray500
                              : AppColors.accent),
                  size: isCompact ? 24 : 28,
                ),
              ),
              SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            widget.isSelected
                                ? AppColors.accent
                                : (widget.isDark
                                    ? AppColors.white
                                    : AppColors.black),
                        fontSize: isCompact ? 15 : 16,
                        fontWeight:
                            widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.songsCount(widget.playlist.fileCount),
                      style: TextStyle(
                        color:
                            widget.isDark
                                ? AppColors.gray500
                                : AppColors.gray600,
                        fontSize: isCompact ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isHovered && !isCompact) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                  iconSize: 20,
                  onPressed: widget.onRename,
                  tooltip: l10n.renamePlaylist,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  color: AppColors.error,
                  iconSize: 20,
                  onPressed: widget.onDelete,
                  tooltip: l10n.deletePlaylist,
                ),
              ],
              if (!_isHovered || isCompact)
                Icon(
                  Icons.chevron_right_rounded,
                  color: widget.isDark ? AppColors.gray600 : AppColors.gray400,
                  size: 24,
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
              Icons.playlist_add_rounded,
              color: isDark ? AppColors.gray500 : AppColors.accent,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.noPlaylists,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.noPlaylistsHint,
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
