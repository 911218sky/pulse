import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/durations.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';

/// A list for selecting folders to include in the music library
class FolderSelectionList extends StatelessWidget {
  const FolderSelectionList({
    required this.folders,
    required this.onToggle,
    super.key,
    this.isDark,
    this.onSelectAll,
    this.onDeselectAll,
  });

  final List<ScannedFolder> folders;
  final void Function(String path) onToggle;
  final bool? isDark;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;

  bool _isDark(BuildContext context) =>
      isDark ?? Theme.of(context).brightness == Brightness.dark;

  int get _selectedCount => folders.where((f) => f.isSelected).length;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with select all/none buttons
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                '$_selectedCount / ${folders.length}',
                style: TextStyle(
                  color: dark ? AppColors.gray400 : AppColors.gray600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (onSelectAll != null)
                VercelButton(
                  label: 'All',
                  variant: VercelButtonVariant.ghost,
                  size: VercelButtonSize.small,
                  isDark: dark,
                  onPressed: onSelectAll,
                ),
              if (onDeselectAll != null) ...[
                const SizedBox(width: AppSpacing.sm),
                VercelButton(
                  label: 'None',
                  variant: VercelButtonVariant.ghost,
                  size: VercelButtonSize.small,
                  isDark: dark,
                  onPressed: onDeselectAll,
                ),
              ],
            ],
          ),
        ),
        Divider(color: dark ? AppColors.gray800 : AppColors.gray200, height: 1),
        // Folder list
        Expanded(
          child: ListView.builder(
            itemCount: folders.length,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemBuilder:
                (context, index) => _FolderItem(
                  folder: folders[index],
                  isDark: dark,
                  onToggle: () => onToggle(folders[index].path),
                ),
          ),
        ),
      ],
    );
  }
}

class _FolderItem extends StatefulWidget {
  const _FolderItem({
    required this.folder,
    required this.isDark,
    required this.onToggle,
  });

  final ScannedFolder folder;
  final bool isDark;
  final VoidCallback onToggle;

  @override
  State<_FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<_FolderItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        color:
            _isHovered
                ? (widget.isDark ? AppColors.gray900 : AppColors.gray100)
                : Colors.transparent,
        child: Row(
          children: [
            // Checkbox
            _Checkbox(
              isChecked: widget.folder.isSelected,
              isDark: widget.isDark,
            ),
            const SizedBox(width: AppSpacing.md),
            // Folder icon
            Icon(
              Icons.folder_rounded,
              color: widget.isDark ? AppColors.gray400 : AppColors.accent,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            // Folder info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.folder.name,
                    style: TextStyle(
                      color:
                          widget.folder.isSelected
                              ? (widget.isDark
                                  ? AppColors.white
                                  : AppColors.black)
                              : (widget.isDark
                                  ? AppColors.gray300
                                  : AppColors.gray700),
                      fontSize: 14,
                      fontWeight:
                          widget.folder.isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.folder.path,
                    style: TextStyle(
                      color:
                          widget.isDark ? AppColors.gray500 : AppColors.gray500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // File count
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.gray800 : AppColors.gray200,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                '${widget.folder.fileCount}',
                style: TextStyle(
                  color: widget.isDark ? AppColors.gray400 : AppColors.gray600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.isChecked, required this.isDark});

  final bool isChecked;
  final bool isDark;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AppDurations.fast,
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color:
          isChecked
              ? (isDark ? AppColors.white : AppColors.accent)
              : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color:
            isChecked
                ? (isDark ? AppColors.white : AppColors.accent)
                : (isDark ? AppColors.gray600 : AppColors.gray400),
        width: 2,
      ),
    ),
    child:
        isChecked
            ? Icon(
              Icons.check_rounded,
              color: isDark ? AppColors.black : AppColors.white,
              size: 14,
            )
            : null,
  );
}

/// A summary card showing selected folders
class FolderSelectionSummary extends StatelessWidget {
  const FolderSelectionSummary({
    required this.selectedCount,
    required this.totalFileCount,
    super.key,
    this.isDark,
    this.onSave,
    this.isSaving = false,
  });

  final int selectedCount;
  final int totalFileCount;
  final bool? isDark;
  final VoidCallback? onSave;
  final bool isSaving;

  bool _isDark(BuildContext context) =>
      isDark ?? Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: dark ? AppColors.gray900 : AppColors.gray100,
        border: Border(
          top: BorderSide(color: dark ? AppColors.gray800 : AppColors.gray200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$selectedCount folders',
                  style: TextStyle(
                    color: dark ? AppColors.white : AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$totalFileCount tracks',
                  style: TextStyle(
                    color: dark ? AppColors.gray400 : AppColors.gray600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          VercelButton(
            label: l10n.save,
            isLoading: isSaving,
            isDisabled: selectedCount == 0,
            isDark: dark,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}
