import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';

/// Result of file import dialog
class FileImportResult {
  const FileImportResult({this.files = const [], this.folders = const []});

  final List<String> files;
  final List<String> folders;

  bool get isEmpty => files.isEmpty && folders.isEmpty;
  int get totalCount => files.length + folders.length;
}

/// Dialog for importing files and folders manually
class FileImportDialog extends StatefulWidget {
  const FileImportDialog({super.key});

  static Future<FileImportResult?> show(BuildContext context) =>
      showDialog<FileImportResult>(
        context: context,
        builder: (context) => const FileImportDialog(),
      );

  @override
  State<FileImportDialog> createState() => _FileImportDialogState();
}

class _FileImportDialogState extends State<FileImportDialog> {
  final List<String> _selectedFiles = [];
  final List<String> _selectedFolders = [];
  bool _isLoading = false;

  Future<void> _pickFiles() async {
    setState(() => _isLoading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'flac', 'aac', 'm4a', 'ogg', 'wma'],
        allowMultiple: true,
      );

      if (result != null) {
        final paths =
            result.paths
                .where((p) => p != null)
                .cast<String>()
                .where((p) => !_selectedFiles.contains(p))
                .toList();
        setState(() => _selectedFiles.addAll(paths));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFolder() async {
    setState(() => _isLoading = true);

    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result != null && !_selectedFolders.contains(result)) {
        setState(() => _selectedFolders.add(result));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeFile(String path) {
    setState(() => _selectedFiles.remove(path));
  }

  void _removeFolder(String path) {
    setState(() => _selectedFolders.remove(path));
  }

  void _submit() {
    Navigator.of(
      context,
    ).pop(FileImportResult(files: _selectedFiles, folders: _selectedFolders));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 400 ? screenWidth * 0.9 : 400.0;
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.gray900 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: isDark ? AppColors.gray700 : AppColors.gray200),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.importMusic,
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColors.gray900,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.importMusicDesc,
                style: TextStyle(
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Action buttons
              Column(
                children: [
                  VercelButton(
                    label: l10n.selectFiles,
                    icon: Icons.audio_file_rounded,
                    variant: VercelButtonVariant.secondary,
                    isLoading: _isLoading,
                    onPressed: _pickFiles,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  VercelButton(
                    label: l10n.selectFolder,
                    icon: Icons.folder_rounded,
                    variant: VercelButtonVariant.secondary,
                    isLoading: _isLoading,
                    onPressed: _pickFolder,
                    fullWidth: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Selected items list
              if (_selectedFiles.isNotEmpty || _selectedFolders.isNotEmpty)
                Flexible(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.black : AppColors.gray50,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isDark ? AppColors.gray800 : AppColors.gray200,
                      ),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      children: [
                        ..._selectedFolders.map(
                          (path) => _SelectedItem(
                            path: path,
                            isFolder: true,
                            isDark: isDark,
                            onRemove: () => _removeFolder(path),
                          ),
                        ),
                        ..._selectedFiles.map(
                          (path) => _SelectedItem(
                            path: path,
                            isDark: isDark,
                            onRemove: () => _removeFile(path),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.black : AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isDark ? AppColors.gray800 : AppColors.gray200,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color:
                                isDark ? AppColors.gray600 : AppColors.gray400,
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.noFilesSelected,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.gray500
                                      : AppColors.gray600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              // Footer
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: VercelButton(
                          label: l10n.cancel,
                          variant: VercelButtonVariant.ghost,
                          onPressed: () => Navigator.of(context).pop(),
                          fullWidth: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: VercelButton(
                          label: l10n.import,
                          isDisabled:
                              _selectedFiles.isEmpty &&
                              _selectedFolders.isEmpty,
                          onPressed: _submit,
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedItem extends StatefulWidget {
  const _SelectedItem({
    required this.path,
    required this.onRemove,
    required this.isDark,
    this.isFolder = false,
  });

  final String path;
  final bool isFolder;
  final bool isDark;
  final VoidCallback onRemove;

  @override
  State<_SelectedItem> createState() => _SelectedItemState();
}

class _SelectedItemState extends State<_SelectedItem> {
  bool _isHovered = false;

  String get _displayName {
    final parts = widget.path.split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : widget.path;
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color:
            _isHovered
                ? (widget.isDark ? AppColors.gray900 : AppColors.gray100)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            widget.isFolder ? Icons.folder_rounded : Icons.audio_file_rounded,
            color:
                widget.isFolder
                    ? AppColors.warning
                    : (widget.isDark ? AppColors.gray400 : AppColors.gray500),
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayName,
                  style: TextStyle(
                    color: widget.isDark ? AppColors.white : AppColors.gray900,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.path,
                  style: TextStyle(
                    color:
                        widget.isDark ? AppColors.gray600 : AppColors.gray500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_isHovered)
            GestureDetector(
              onTap: widget.onRemove,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.close_rounded,
                  color: widget.isDark ? AppColors.gray400 : AppColors.gray500,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
