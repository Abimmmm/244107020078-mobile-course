import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/todo_page.dart';
import 'pages/stats_pages.dart';

/// Shell yang membungkus halaman dengan NavigationBar di bawah.
/// StatefulShellRoute.indexedStack menjaga state tiap branch tetap hidup
/// (pakai IndexedStack di balik layar) — ini yang membuat state ToDo
/// TIDAK reset saat pindah ke /stats lalu balik lagi ke /.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'ToDo'),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (c, s) => const TodoPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/stats', builder: (c, s) => const StatsPage()),
          ],
        ),
      ],
    ),
  ],
);
