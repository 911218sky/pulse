import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';
import 'package:pulse/presentation/widgets/player/mini_player.dart';

/// App shell that wraps screens with mini player
class AppShell extends StatelessWidget {
  const AppShell({required this.child, this.showMiniPlayer = true, super.key});

  final Widget child;
  final bool showMiniPlayer;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isPlayerScreen = location == AppRoutes.player;
    final palette = context.appPalette;

    return ColoredBox(
      color: palette.background,
      child: Column(
        children: [
          Expanded(child: child),
          if (showMiniPlayer && !isPlayerScreen)
            MiniPlayer(onTap: () => context.push(AppRoutes.player)),
        ],
      ),
    );
  }
}
