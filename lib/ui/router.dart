import 'package:articles_kindle/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme/tokens.dart';
import 'screens/history_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/send_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/site_discovery_screen.dart';
import 'screens/to_read_screen.dart';

/// Les quatre onglets. Pas d'onglet « Flux » : le flux n'est qu'un moyen de
/// découvrir les articles d'un site quand on le demande.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/read',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/read',
                builder: (context, state) => const ToReadScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/send',
                builder: (context, state) => const SendScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/site',
        builder: (context, state) => const SiteDiscoveryScreen(),
      ),
      GoRoute(
        path: '/reader/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ReaderScreen(articleId: id);
        },
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            label: l10n.tabToRead,
          ),
          NavigationDestination(
            icon: const Icon(Icons.outbox_outlined),
            label: l10n.tabSend,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: l10n.tabHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}

/// Style d'une feuille modale : bord liseré, coins droits.
const einkSheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.zero,
  side: BorderSide(width: Eink.borderWidthStrong, color: Colors.black),
);
