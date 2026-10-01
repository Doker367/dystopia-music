import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dystopia/presentation/widgets/floating_nav_bar.dart';
import 'package:dystopia/presentation/widgets/mini_player.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // Main tab content
          navigationShell,

          // Bottom dock: MiniPlayer + FloatingNavBar kept fixed at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayer(),
                DystopiaFloatingNavBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
