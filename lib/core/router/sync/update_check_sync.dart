import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';
import 'package:pulse/presentation/controllers/update_flow_controller.dart';

/// Runs one silent startup update check when the user enables it.
class UpdateCheckSync extends StatefulWidget {
  const UpdateCheckSync({
    required this.child,
    this.updateFlow = const UpdateFlowController(),
    this.retryDelay = const Duration(seconds: 15),
    this.updateContextProvider,
    super.key,
  });

  final Widget child;
  final UpdateFlowController updateFlow;
  final Duration retryDelay;
  final BuildContext? Function()? updateContextProvider;

  @override
  State<UpdateCheckSync> createState() => _UpdateCheckSyncState();
}

class _UpdateCheckSyncState extends State<UpdateCheckSync> {
  bool _hasChecked = false;
  bool _hasRetried = false;

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
    final settingsBloc = context.read<SettingsBloc>();
    final updateContext =
        widget.updateContextProvider?.call() ??
        AppRouter.rootNavigatorKey.currentContext;
    if (updateContext == null) {
      _hasChecked = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeCheckForUpdate(settingsBloc.state);
      });
      return;
    }

    final outcome = await widget.updateFlow.checkForUpdate(
      updateContext,
      trigger: UpdateCheckTrigger.automatic,
    );

    if (!mounted ||
        _hasRetried ||
        outcome != UpdateCheckOutcome.failed ||
        !settingsBloc.state.settings.autoUpdateEnabled) {
      return;
    }

    _hasRetried = true;
    await Future<void>.delayed(widget.retryDelay);
    if (mounted && settingsBloc.state.settings.autoUpdateEnabled) {
      final retryContext =
          widget.updateContextProvider?.call() ??
          AppRouter.rootNavigatorKey.currentContext;
      if (retryContext == null || !retryContext.mounted) return;
      await widget.updateFlow.checkForUpdate(
        retryContext,
        trigger: UpdateCheckTrigger.automatic,
      );
    }
  }
}
