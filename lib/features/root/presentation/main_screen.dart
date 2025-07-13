import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  static const _tabs = ['/walls', '/about'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere((path) => location.startsWith(path));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex == -1 ? 0 : currentIndex,
        onTap: (index) => context.go(_tabs[index]),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.texture), label: 'ウォール'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'アプリについて'),
        ],
      ),
    );
  }
}
