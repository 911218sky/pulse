import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';
import 'package:pulse/presentation/controllers/update_flow_controller.dart';

/// Runs one silent startup update check when the user enables it.
class UpdateCheckSync extends StatefulWidget {
  const UpdateCheckSync({required this.child, super.key});

  final Widget child;

  @override
  State<UpdateCheckSync> createState() => _UpdateCheckSyncState();
}

class _UpdateCheckSyncState extends State<UpdateCheckSync> {
  bool _hasChecked = false;
  final _updateFlow = const UpdateFlowController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeCheckForUpdate(context.read<SettingsBloc>().state);
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<SettingsBloc, SettingsState>(
        listenWhen:
            (previous, current) =>
                previous.status != current.status ||
                previous.settings.autoUpdateEnabled !=
                    current.settings.autoUpdateEnabled,
        listener: (context, state) => _maybeCheckForUpdate(state),
        child: widget.child,
      );

  void _maybeCheckForUpdate(SettingsState state) {
    if (_hasChecked ||
        state.status != SettingsStatus.loaded ||
        !state.settings.autoUpdateEnabled) {
      return;
    }

    _hasChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    await _updateFlow.checkForUpdate(
      context,
      trigger: UpdateCheckTrigger.automatic,
    );
  }
}
