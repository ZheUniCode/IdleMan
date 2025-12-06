// ============================================================================
// IDLEMAN v16.0 - HOME SCREEN
// ============================================================================
// File: lib/features/dashboard/screens/home_screen.dart
// Purpose: Main navigation hub with bottom navigation
// Philosophy: Easy access to all features, no overwhelm
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/theme/therapy_theme.dart';
import 'package:idleman/features/reflection/screens/reflection_screen.dart';
import 'package:idleman/features/digest/screens/digest_screen.dart';
import 'package:idleman/features/garden/screens/garden_screen.dart';
import 'package:idleman/features/settings/screens/settings_screen.dart';
import 'package:idleman/features/digest/providers/digest_provider.dart';

// ============================================================================
// HOME SCREEN
// ============================================================================
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // Screen definitions
  final List<Widget> _screens = const [
    ReflectionScreen(),
    DigestScreen(),
    GardenScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('[HomeScreen::initState] Initializing home screen.');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[HomeScreen::build] Building with index: $_currentIndex');

    // Watch digest for badge
    final pendingCount = ref.watch(pendingNotificationsCountProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(pendingCount),
    );
  }

  Widget _buildBottomNav(int pendingCount) {
    return Container(
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        boxShadow: [
          BoxShadow(
            color: TherapyColors.ink.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.visibility_outlined,
                activeIcon: Icons.visibility,
                label: 'Reflect',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Digest',
                badge: pendingCount > 0 ? pendingCount : null,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.eco_outlined,
                activeIcon: Icons.eco,
                label: 'Garden',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badge,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? TherapyColors.growth.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? TherapyColors.growth : TherapyColors.graphite,
                  size: 24,
                ),
                // Badge
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: TherapyColors.boundary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        badge > 99 ? '99+' : badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TherapyText.caption().copyWith(
                color: isActive ? TherapyColors.growth : TherapyColors.graphite,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
