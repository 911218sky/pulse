import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pulse/core/l10n/app_localizations.dart';

/// Keyboard shortcut actions
enum KeyboardAction {
  playPause,
  skipForward,
  skipBackward,
  volumeUp,
  volumeDown,
  toggleMute,
  nextTrack,
  previousTrack,
}

/// A widget that handles keyboard shortcuts for the music player
class KeyboardShortcuts extends StatelessWidget {
  const KeyboardShortcuts({
    required this.child,
    required this.onAction,
    super.key,
    this.enabled = true,
  });

  final Widget child;
  final void Function(KeyboardAction action) onAction;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: _buildActions(),
        child: Focus(autofocus: true, child: child),
      ),
    );
  }

  static final Map<ShortcutActivator, Intent> _shortcuts = {
    // Space - Play/Pause
    const SingleActivator(LogicalKeyboardKey.space): const _KeyboardIntent(
      KeyboardAction.playPause,
    ),
    // K - Play/Pause (YouTube style)
    const SingleActivator(LogicalKeyboardKey.keyK): const _KeyboardIntent(
      KeyboardAction.playPause,
    ),
    // Right Arrow - Skip Forward
    const SingleActivator(LogicalKeyboardKey.arrowRight): const _KeyboardIntent(
      KeyboardAction.skipForward,
    ),
    // L - Skip Forward (YouTube style)
    const SingleActivator(LogicalKeyboardKey.keyL): const _KeyboardIntent(
      KeyboardAction.skipForward,
    ),
    // Left Arrow - Skip Backward
    const SingleActivator(LogicalKeyboardKey.arrowLeft): const _KeyboardIntent(
      KeyboardAction.skipBackward,
    ),
    // J - Skip Backward (YouTube style)
    const SingleActivator(LogicalKeyboardKey.keyJ): const _KeyboardIntent(
      KeyboardAction.skipBackward,
    ),
    // Up Arrow - Volume Up
    const SingleActivator(LogicalKeyboardKey.arrowUp): const _KeyboardIntent(
      KeyboardAction.volumeUp,
    ),
    // Down Arrow - Volume Down
    const SingleActivator(LogicalKeyboardKey.arrowDown): const _KeyboardIntent(
      KeyboardAction.volumeDown,
    ),
    // M - Toggle Mute
    const SingleActivator(LogicalKeyboardKey.keyM): const _KeyboardIntent(
      KeyboardAction.toggleMute,
    ),
    // N - Next Track
    const SingleActivator(LogicalKeyboardKey.keyN): const _KeyboardIntent(
      KeyboardAction.nextTrack,
    ),
    // Shift + N - Previous Track
    const SingleActivator(
      LogicalKeyboardKey.keyN,
      shift: true,
    ): const _KeyboardIntent(KeyboardAction.previousTrack),
    // P - Previous Track
    const SingleActivator(LogicalKeyboardKey.keyP): const _KeyboardIntent(
      KeyboardAction.previousTrack,
    ),
    // Period (>) - Next Track
    const SingleActivator(
      LogicalKeyboardKey.period,
      shift: true,
    ): const _KeyboardIntent(KeyboardAction.nextTrack),
    // Comma (<) - Previous Track
    const SingleActivator(
      LogicalKeyboardKey.comma,
      shift: true,
    ): const _KeyboardIntent(KeyboardAction.previousTrack),
  };

  Map<Type, Action<Intent>> _buildActions() => {
    _KeyboardIntent: CallbackAction<_KeyboardIntent>(
      onInvoke: (intent) {
        onAction(intent.action);
        return null;
      },
    ),
  };
}

class _KeyboardIntent extends Intent {
  const _KeyboardIntent(this.action);

  final KeyboardAction action;
}

/// A mixin that provides keyboard shortcut handling for player screens
mixin KeyboardShortcutsMixin<T extends StatefulWidget> on State<T> {
  /// Override this to handle keyboard actions
  void handleKeyboardAction(KeyboardAction action);

  /// Build a widget wrapped with keyboard shortcuts
  Widget buildWithKeyboardShortcuts({
    required Widget child,
    bool enabled = true,
  }) => KeyboardShortcuts(
    enabled: enabled,
    onAction: handleKeyboardAction,
    child: child,
  );
}

/// Keyboard shortcuts help dialog
class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => const KeyboardShortcutsHelp(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.keyboardShortcuts),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShortcutRow(keys: 'Space / K', description: l10n.playPause),
            _ShortcutRow(keys: '← / J', description: l10n.rewind),
            _ShortcutRow(keys: '→ / L', description: l10n.fastForward),
            _ShortcutRow(keys: '↑', description: l10n.volumeUp),
            _ShortcutRow(keys: '↓', description: l10n.volumeDown),
            _ShortcutRow(keys: 'M', description: l10n.muteToggle),
            _ShortcutRow(keys: 'N / Shift+>', description: l10n.nextTrack),
            _ShortcutRow(keys: 'P / Shift+<', description: l10n.previousTrack),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.keys, required this.description});

  final String keys;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            keys,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Text(description)),
      ],
    ),
  );
}
