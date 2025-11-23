import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/blocklist_provider.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_toggle.dart';

/// Settings Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final blocklist = ref.watch(blocklistProvider);
    final blocklistNotifier = ref.read(blocklistProvider.notifier);

    return Scaffold(
      backgroundColor: theme.background,
      body: NeuBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.mainText,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      AppStrings.settingsTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.mainText,
                        // fontFamily removed
                      ),
                    ),
                  ],
                ),
              ),
              // Settings list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  children: [
                    // Theme toggle
                    NeuCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                theme.isDark
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: theme.accent,
                                size: 28,
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.settingsThemeToggle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: theme.mainText,
                                      // fontFamily removed
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    theme.isDark
                                        ? AppStrings.settingsThemeNight
                                        : AppStrings.settingsThemeDay,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.mainText.withOpacity(0.6),
                                      // fontFamily removed
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          NeuToggle(
                            value: theme.isDark,
                            onChanged: (_) => themeNotifier.toggleTheme(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    // Blocked apps section
                    Text(
                      AppStrings.settingsBlocklist,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.mainText.withOpacity(0.7),
                        // fontFamily removed
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    // Blocked apps list
                    if (blocklist.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.paddingLarge),
                          child: Text('Loading apps...'),
                        ),
                      )
                    else
                      ...blocklist.take(10).map((app) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.paddingSmall),
                          child: NeuCard(
                            padding:
                                const EdgeInsets.all(AppConstants.paddingMedium),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    app.appName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.mainText,
                                      // fontFamily removed
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.paddingSmall),
                                NeuToggle(
                                  value: app.isBlocked,
                                  onChanged: (_) {
                                    blocklistNotifier.toggleApp(app.packageName);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: AppConstants.paddingMedium),
                    // Permissions section
                    Text(
                      AppStrings.settingsPermissions,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.mainText.withOpacity(0.7),
                        // fontFamily removed
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    NeuCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.accessibility,
                            color: theme.accent,
                            size: 28,
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Accessibility Service',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.mainText,
                                    // fontFamily removed
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Required for app monitoring',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.mainText.withOpacity(0.6),
                                    // fontFamily removed
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
