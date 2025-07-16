import 'package:go_router/go_router.dart';

import 'package:borudaruma/features/root/presentation/main_screen.dart';
import 'package:borudaruma/features/about/presentation/about_screen.dart';

import 'package:borudaruma/features/wall/presentation/wall_list_screen.dart';
import 'package:borudaruma/features/wall/presentation/wall_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/walls',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        // ボトムナビゲーションバー有りのroutes
        GoRoute(
          path: '/walls',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WallListScreen()),
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AboutScreen()),
        ),
      ],
    ),

    // ボトムナビゲーションバー無しのroutes
    
    GoRoute(
      path: '/walls/detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return WallDetailScreen(id: id);
      },
    ),
  ],
);
