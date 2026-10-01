import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DystopiaFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DystopiaFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_TabItemData> _tabs = [
    _TabItemData(
      label: 'Inicio',
      selectedIcon: Icons.grid_view_rounded,
      unselectedIcon: Icons.grid_view_outlined,
    ),
    _TabItemData(
      label: 'Explorar',
      selectedIcon: Icons.travel_explore_rounded,
      unselectedIcon: Icons.search_rounded,
    ),
    _TabItemData(
      label: 'Biblioteca',
      selectedIcon: Icons.library_music_rounded,
      unselectedIcon: Icons.library_music_outlined,
    ),
    _TabItemData(
      label: 'Descargas',
      selectedIcon: Icons.offline_bolt_rounded,
      unselectedIcon: Icons.offline_bolt_outlined,
    ),
    _TabItemData(
      label: 'Ajustes',
      selectedIcon: Icons.tune_rounded,
      unselectedIcon: Icons.tune_outlined,
    ),
  ];

  void _handleDragPosition(Offset localPos, double totalWidth) {
    if (totalWidth <= 0) return;
    final tabWidth = totalWidth / _tabs.length;
    final index = (localPos.dx / tabWidth).floor().clamp(0, _tabs.length - 1);
    if (index != currentIndex) {
      HapticFeedback.selectionClick();
      onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF121214).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFA8B545).withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFA8B545).withValues(alpha: 0.08),
                  blurRadius: 15,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final tabWidth = totalWidth / _tabs.length;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (d) => _handleDragPosition(d.localPosition, totalWidth),
                  onPanUpdate: (d) => _handleDragPosition(d.localPosition, totalWidth),
                  child: Stack(
                    children: [
                      // Smoothly sliding animated capsule indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        left: currentIndex * tabWidth + 4,
                        top: 7,
                        bottom: 7,
                        width: tabWidth - 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8B545).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFA8B545).withValues(alpha: 0.45),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA8B545).withValues(alpha: 0.22),
                                blurRadius: 12,
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Row of tab buttons with icon & animated label
                      Row(
                        children: List.generate(_tabs.length, (index) {
                          final tab = _tabs[index];
                          final isSelected = index == currentIndex;
                          const activeColor = Color(0xFFA8B545);
                          const inactiveColor = Color(0xFF8E8E93);

                          return SizedBox(
                            width: tabWidth,
                            height: 64,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onTap(index);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    scale: isSelected ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutBack,
                                    child: Icon(
                                      isSelected ? tab.selectedIcon : tab.unselectedIcon,
                                      color: isSelected ? activeColor : inactiveColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : inactiveColor,
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                    child: Text(
                                      tab.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItemData {
  final String label;
  final IconData selectedIcon;
  final IconData unselectedIcon;

  const _TabItemData({
    required this.label,
    required this.selectedIcon,
    required this.unselectedIcon,
  });
}
