import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/stats_provider.dart';
import '../../core/providers/blocklist_provider.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_button.dart';

/// Main Dashboard (Home Screen)
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final stats = ref.watch(statsProvider);
    final blocklist = ref.watch(blocklistProvider);
    final blockedCount = blocklist.where((app) => app.isBlocked).length;

    return Scaffold(
      backgroundColor: theme.background,
      body: NeuBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with settings button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.mainText,
                        // fontFamily removed
                      ),
                    ),
                    NeuIconButton(
                      icon: Icons.settings,
                      onTap: () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingXLarge),
                // Status card
                NeuCard(
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.accent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: theme.accent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.dashboardActiveStatus,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: theme.mainText,
                                // fontFamily removed
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Monitoring your apps',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.mainText.withOpacity(0.6),
                                // fontFamily removed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                // Stats section title
                Text(
                  'Today\'s Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.mainText,
                    // fontFamily removed
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                // Stats cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatCard(
                        theme,
                        Icons.block,
                        '${stats.interruptionsToday}',
                        AppStrings.dashboardInterruptionsToday,
                      ),
                      _buildStatCard(
                        theme,
                        Icons.apps,
                        '$blockedCount',
                        AppStrings.dashboardAppsBlocked,
                      ),
                      _buildStatCard(
                        theme,
                        Icons.timer,
                        '${stats.minutesSaved}m',
                        'Time Saved',
                      ),
                      _buildStatCard(
                        theme,
                        Icons.trending_up,
                        '${stats.improvementPercent.toInt()}%',
                        'Improvement',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(theme, IconData icon, String value, String label) {
    return NeuCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: theme.accent,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.mainText,
              // fontFamily removed
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: theme.mainText.withOpacity(0.6),
              // fontFamily removed
            ),
          ),
        ],
      ),
    );
  }
}
