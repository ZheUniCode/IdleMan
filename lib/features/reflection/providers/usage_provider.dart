// ============================================================================
// IDLEMAN v16.0 - USAGE PROVIDER
// ============================================================================
// File: lib/features/reflection/providers/usage_provider.dart
// Purpose: Riverpod state management for app usage data
// Philosophy: "Reflect" on usage, don't "Surveil" - compassionate data access
// ============================================================================

// Import Flutter foundation for debugPrint and Platform
import 'package:flutter/foundation.dart';

// Import Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import our app usage model
import 'package:idleman/features/reflection/models/app_usage_model.dart';

// Import Hive service for storing boundary configurations
import 'package:idleman/core/services/hive_service.dart';

// Import NativeBridge for real UsageStats
import 'package:idleman/core/services/native_bridge.dart';

// ============================================================================
// USAGE STATE
// ============================================================================
// Immutable state object for the usage provider
// Contains the list of apps and loading/error states
// ============================================================================
class UsageState {
  // -------------------------------------------------------------------------
  // LIST OF APPS - All apps with their usage data
  // -------------------------------------------------------------------------
  final List<AppUsageModel> apps;

  // -------------------------------------------------------------------------
  // IS LOADING - Whether we're currently fetching data
  // -------------------------------------------------------------------------
  final bool isLoading;

  // -------------------------------------------------------------------------
  // ERROR MESSAGE - Any error that occurred during fetch
  // -------------------------------------------------------------------------
  final String? errorMessage;

  // -------------------------------------------------------------------------
  // SELECTED CATEGORY - Current filter category
  // -------------------------------------------------------------------------
  final AppCategory selectedCategory;

  // -------------------------------------------------------------------------
  // SELECTED PERIOD - Current time period for stats
  // -------------------------------------------------------------------------
  final UsageStatsPeriod selectedPeriod;

  // -------------------------------------------------------------------------
  // CONSTRUCTOR
  // -------------------------------------------------------------------------
  const UsageState({
    // Default to empty list
    this.apps = const [],
    // Default to loading state
    this.isLoading = true,
    // Default to no error
    this.errorMessage,
    // Default to "All" category
    this.selectedCategory = AppCategory.all,
    // Default to "Today" period
    this.selectedPeriod = UsageStatsPeriod.today,
  });

  // -------------------------------------------------------------------------
  // GETTER: Filtered apps based on selected category
  // Returns only apps that match the current filter
  // -------------------------------------------------------------------------
  List<AppUsageModel> get filteredApps {
    // Log entry into the getter
    debugPrint('[UsageState::filteredApps] Filtering apps by category: ${selectedCategory.displayName}');
    
    // First, filter to only reflectable apps
    final reflectableApps = apps.where((app) => app.isReflectable).toList();
    
    // Log the count of reflectable apps
    debugPrint('[UsageState::filteredApps] Reflectable apps count: ${reflectableApps.length}');
    
    // Apply category-specific filtering
    List<AppUsageModel> filtered;
    
    switch (selectedCategory) {
      // ALL - Return all reflectable apps sorted by usage
      case AppCategory.all:
        debugPrint('[UsageState::filteredApps] Showing all apps.');
        filtered = reflectableApps;
        break;
      
      // FOCUS THIEVES - Sort by usage time descending
      case AppCategory.focusThieves:
        debugPrint('[UsageState::filteredApps] Sorting by usage time (Focus Thieves).');
        filtered = List.from(reflectableApps)
          ..sort((a, b) => b.usageTimeMs.compareTo(a.usageTimeMs));
        break;
      
      // SOCIAL - Filter to social media apps
      case AppCategory.social:
        debugPrint('[UsageState::filteredApps] Filtering social media apps.');
        filtered = reflectableApps.where((app) {
          // Check if package name contains known social media identifiers
          final pkg = app.packageName.toLowerCase();
          return pkg.contains('instagram') ||
              pkg.contains('tiktok') ||
              pkg.contains('facebook') ||
              pkg.contains('twitter') ||
              pkg.contains('snapchat') ||
              pkg.contains('whatsapp') ||
              pkg.contains('telegram') ||
              pkg.contains('discord') ||
              pkg.contains('reddit') ||
              pkg.contains('linkedin') ||
              app.category?.toLowerCase() == 'social';
        }).toList();
        break;
      
      // GAMES - Filter to gaming apps
      case AppCategory.games:
        debugPrint('[UsageState::filteredApps] Filtering game apps.');
        filtered = reflectableApps.where((app) {
          // Check category or package name patterns
          return app.category?.toLowerCase() == 'games' ||
              app.category?.toLowerCase() == 'game';
        }).toList();
        break;
      
      // ENTERTAINMENT - Filter to video/streaming apps
      case AppCategory.entertainment:
        debugPrint('[UsageState::filteredApps] Filtering entertainment apps.');
        filtered = reflectableApps.where((app) {
          final pkg = app.packageName.toLowerCase();
          return pkg.contains('youtube') ||
              pkg.contains('netflix') ||
              pkg.contains('twitch') ||
              pkg.contains('hulu') ||
              pkg.contains('prime') ||
              pkg.contains('spotify') ||
              pkg.contains('disney') ||
              app.category?.toLowerCase() == 'entertainment' ||
              app.category?.toLowerCase() == 'video';
        }).toList();
        break;
      
      // NEW ARRIVALS - Apps installed recently (mock: just return all for now)
      case AppCategory.newArrivals:
        debugPrint('[UsageState::filteredApps] Filtering new arrivals.');
        // In a real implementation, we'd check install date
        // For now, return apps with lower usage (likely newer)
        filtered = reflectableApps.where((app) => app.usageTimeMs < 3600000).toList();
        break;
    }
    
    // Log the filtered count
    debugPrint('[UsageState::filteredApps] Filtered apps count: ${filtered.length}');
    
    // Return the filtered list
    return filtered;
  }

  // -------------------------------------------------------------------------
  // GETTER: Total usage time across all apps
  // Returns formatted string for display
  // -------------------------------------------------------------------------
  String get totalUsageFormatted {
    // Log entry into the getter
    debugPrint('[UsageState::totalUsageFormatted] Calculating total usage.');
    
    // Sum up all usage times
    final totalMs = apps.fold<int>(0, (sum, app) => sum + app.usageTimeMs);
    
    // Convert to duration
    final duration = Duration(milliseconds: totalMs);
    
    // Format as hours and minutes
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    // Build the formatted string
    final formatted = '${hours}h ${minutes}m';
    
    // Log the result
    debugPrint('[UsageState::totalUsageFormatted] Total usage: $formatted');
    
    // Return the formatted string
    return formatted;
  }

  // -------------------------------------------------------------------------
  // COPY WITH - Creates a copy with modified properties
  // Used for immutable state updates
  // -------------------------------------------------------------------------
  UsageState copyWith({
    List<AppUsageModel>? apps,
    bool? isLoading,
    String? errorMessage,
    AppCategory? selectedCategory,
    UsageStatsPeriod? selectedPeriod,
  }) {
    // Log entry into the method
    debugPrint('[UsageState::copyWith] Creating state copy.');
    
    // Create and return a new instance
    return UsageState(
      apps: apps ?? this.apps,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

// ============================================================================
// USAGE NOTIFIER
// ============================================================================
// Riverpod Notifier that manages the usage state
// Handles fetching apps, filtering, and boundary updates
// ============================================================================
class UsageNotifier extends Notifier<UsageState> {
  // Reference to NativeBridge for real data
  NativeBridge? _nativeBridge;

  // -------------------------------------------------------------------------
  // BUILD - Initialize the state
  // Called automatically by Riverpod when the provider is first accessed
  // -------------------------------------------------------------------------
  @override
  UsageState build() {
    // Log entry into the build method
    debugPrint('[UsageNotifier::build] Initializing UsageNotifier.');
    
    // Get NativeBridge reference
    _nativeBridge = ref.read(nativeBridgeProvider);
    
    // Schedule app fetch using Future.microtask to ensure it runs after build completes
    // This is the proper pattern for Riverpod Notifier async initialization
    debugPrint('[UsageNotifier::build] Scheduling _fetchApps via Future.microtask...');
    Future.microtask(() {
      debugPrint('[UsageNotifier::build] Microtask executing - calling _fetchApps()');
      _fetchApps();
    });
    
    // Return initial loading state
    debugPrint('[UsageNotifier::build] Returning initial loading state.');
    return const UsageState(isLoading: true);
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Fetch apps from the system or return mock data
  // Uses real UsageStats on Android, mock data otherwise
  // -------------------------------------------------------------------------
  Future<void> _fetchApps() async {
    // Log entry into the method - IMMEDIATE LOG TO VERIFY EXECUTION
    debugPrint('[UsageNotifier::_fetchApps] ==============================');
    debugPrint('[UsageNotifier::_fetchApps] STARTED FETCHING APPS');
    debugPrint('[UsageNotifier::_fetchApps] ==============================');

    try {
      // Set loading state
      debugPrint('[UsageNotifier::_fetchApps] Setting loading state.');
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Try to get real usage data from native bridge
      debugPrint('[UsageNotifier::_fetchApps] Attempting to fetch real usage data.');
      
      List<AppUsageModel> fetchedApps = [];
      
      // Check if we have usage stats permission
      final hasPermission = await _nativeBridge?.hasUsageStatsPermission() ?? false;
      debugPrint('[UsageNotifier::_fetchApps] Has UsageStats permission: $hasPermission');
      
      if (hasPermission) {
        // Try to get real data from native
        try {
          // Get usage for today
          final now = DateTime.now();
          final startOfDay = DateTime(now.year, now.month, now.day);
          
          final rawApps = await _nativeBridge?.getUsageStats(
            startTime: startOfDay,
            endTime: now,
          ) ?? [];
          debugPrint('[UsageNotifier::_fetchApps] Got ${rawApps.length} apps from native.');
          
          // Convert raw maps to AppUsageModel
          fetchedApps = rawApps.map((raw) {
            return AppUsageModel(
              packageName: raw['packageName'] as String? ?? '',
              appName: raw['appName'] as String? ?? 'Unknown',
              usageTimeMs: raw['usageTimeMs'] as int? ?? 0,
              category: raw['category'] as String?,
              appIcon: raw['appIcon'] != null
                  ? Uint8List.fromList(List<int>.from(raw['appIcon'] as List))
                  : null,
            );
          }).toList();
          
          // Filter out system apps with minimal usage
          fetchedApps = fetchedApps.where((app) => app.usageTimeMs > 60000).toList(); // >1 min
          
        } catch (e) {
          debugPrint('[UsageNotifier::_fetchApps] Native fetch failed: $e');
        }
      }
      
      // Fall back to mock data if no real data available
      if (fetchedApps.isEmpty) {
        debugPrint('[UsageNotifier::_fetchApps] Using mock data (no real data available).');
        await Future.delayed(const Duration(milliseconds: 500));
        fetchedApps = _generateMockData();
      }
      
      // Log the number of apps fetched
      debugPrint('[UsageNotifier::_fetchApps] Total apps: ${fetchedApps.length}');

      // Load boundary configurations from Hive
      debugPrint('[UsageNotifier::_fetchApps] Loading boundary configurations.');
      final boundedApps = await _loadBoundedApps();
      debugPrint('[UsageNotifier::_fetchApps] Loaded ${boundedApps.length} bounded apps.');
      
      // Update apps with boundary status
      final appsWithBoundaries = fetchedApps.map((app) {
        // Check if this app has a boundary set
        final isBounded = boundedApps.contains(app.packageName);
        
        // If bounded, return a copy with isBounded = true
        if (isBounded) {
          debugPrint('[UsageNotifier::_fetchApps] ${app.appName} is bounded.');
          return app.copyWith(isBounded: true);
        }
        
        // Otherwise return the original
        return app;
      }).toList();

      // Sort apps by usage time (descending) by default
      appsWithBoundaries.sort((a, b) => b.usageTimeMs.compareTo(a.usageTimeMs));
      
      // Update state with fetched apps
      debugPrint('[UsageNotifier::_fetchApps] ==============================');
      debugPrint('[UsageNotifier::_fetchApps] UPDATING STATE WITH ${appsWithBoundaries.length} APPS');
      debugPrint('[UsageNotifier::_fetchApps] ==============================');
      state = state.copyWith(
        apps: appsWithBoundaries,
        isLoading: false,
      );
      
      // Log completion
      debugPrint('[UsageNotifier::_fetchApps] ==============================');
      debugPrint('[UsageNotifier::_fetchApps] COMPLETED SUCCESSFULLY!');
      debugPrint('[UsageNotifier::_fetchApps] ==============================');
      
    } catch (e, stackTrace) {
      // Log the error with visible markers
      debugPrint('[UsageNotifier::_fetchApps] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      debugPrint('[UsageNotifier::_fetchApps] ERROR OCCURRED: $e');
      debugPrint('[UsageNotifier::_fetchApps] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      debugPrint('[UsageNotifier::_fetchApps] Stack trace: $stackTrace');
      
      // Update state with error
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load app usage data. Please try again.',
      );
    }
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Generate mock app usage data for development/testing
  // Returns a list of realistic mock apps
  // -------------------------------------------------------------------------
  List<AppUsageModel> _generateMockData() {
    // Log entry into the method
    debugPrint('[UsageNotifier::_generateMockData] Generating mock app data.');
    
    // Create a list of realistic mock apps
    final mockApps = [
      // Social Media Apps
      const AppUsageModel(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        usageTimeMs: 7200000, // 2 hours
        category: 'Social',
      ),
      const AppUsageModel(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        usageTimeMs: 5400000, // 1.5 hours
        category: 'Social',
      ),
      const AppUsageModel(
        packageName: 'com.twitter.android',
        appName: 'X (Twitter)',
        usageTimeMs: 3600000, // 1 hour
        category: 'Social',
      ),
      const AppUsageModel(
        packageName: 'com.facebook.katana',
        appName: 'Facebook',
        usageTimeMs: 2700000, // 45 minutes
        category: 'Social',
      ),
      const AppUsageModel(
        packageName: 'com.snapchat.android',
        appName: 'Snapchat',
        usageTimeMs: 1800000, // 30 minutes
        category: 'Social',
      ),
      const AppUsageModel(
        packageName: 'com.reddit.frontpage',
        appName: 'Reddit',
        usageTimeMs: 2400000, // 40 minutes
        category: 'Social',
      ),
      
      // Entertainment Apps
      const AppUsageModel(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        usageTimeMs: 4500000, // 1.25 hours
        category: 'Entertainment',
      ),
      const AppUsageModel(
        packageName: 'com.netflix.mediaclient',
        appName: 'Netflix',
        usageTimeMs: 3000000, // 50 minutes
        category: 'Entertainment',
      ),
      const AppUsageModel(
        packageName: 'com.spotify.music',
        appName: 'Spotify',
        usageTimeMs: 1500000, // 25 minutes
        category: 'Entertainment',
      ),
      const AppUsageModel(
        packageName: 'tv.twitch.android.app',
        appName: 'Twitch',
        usageTimeMs: 900000, // 15 minutes
        category: 'Entertainment',
      ),
      
      // Games
      const AppUsageModel(
        packageName: 'com.supercell.clashofclans',
        appName: 'Clash of Clans',
        usageTimeMs: 1200000, // 20 minutes
        category: 'Games',
      ),
      const AppUsageModel(
        packageName: 'com.king.candycrushsaga',
        appName: 'Candy Crush',
        usageTimeMs: 600000, // 10 minutes
        category: 'Games',
      ),
      
      // Productivity (to show variety)
      const AppUsageModel(
        packageName: 'com.google.android.gm',
        appName: 'Gmail',
        usageTimeMs: 900000, // 15 minutes
        category: 'Productivity',
      ),
      const AppUsageModel(
        packageName: 'com.slack',
        appName: 'Slack',
        usageTimeMs: 1800000, // 30 minutes
        category: 'Productivity',
      ),
      
      // Messaging
      const AppUsageModel(
        packageName: 'com.whatsapp',
        appName: 'WhatsApp',
        usageTimeMs: 2100000, // 35 minutes
        category: 'Social',
      ),
      const AppUsageModel(
        packageName: 'org.telegram.messenger',
        appName: 'Telegram',
        usageTimeMs: 1200000, // 20 minutes
        category: 'Social',
      ),
      const AppUsageModel(
        packageName: 'com.discord',
        appName: 'Discord',
        usageTimeMs: 1500000, // 25 minutes
        category: 'Social',
      ),
      
      // Browser (borderline - users might want to set boundaries)
      const AppUsageModel(
        packageName: 'com.android.chrome',
        appName: 'Chrome',
        usageTimeMs: 3300000, // 55 minutes
        category: 'Productivity',
        isSystemApp: true,
      ),
    ];
    
    // Log the generated count
    debugPrint('[UsageNotifier::_generateMockData] Generated ${mockApps.length} mock apps.');
    
    // Return the mock apps
    return mockApps;
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Load bounded apps from Hive storage
  // Returns a set of package names that have boundaries set
  // -------------------------------------------------------------------------
  Future<Set<String>> _loadBoundedApps() async {
    // Log entry into the method
    debugPrint('[UsageNotifier::_loadBoundedApps] Loading bounded apps from Hive.');
    
    try {
      // Check if HiveService is initialized
      if (!HiveService().isInitialized) {
        debugPrint('[UsageNotifier::_loadBoundedApps] HiveService not initialized yet.');
        return {};
      }
      
      // Get the boundaries box
      final box = HiveService().boundariesBox;
      
      // Get the list of bounded package names (safely handle null/empty)
      final boundedData = box.get('bounded_packages');
      
      // Safely convert to Set<String>
      Set<String> boundedSet = {};
      if (boundedData != null && boundedData is List) {
        boundedSet = boundedData.whereType<String>().toSet();
      }
      
      // Log the loaded boundaries
      debugPrint('[UsageNotifier::_loadBoundedApps] Loaded ${boundedSet.length} bounded apps.');
      
      // Return the set
      return boundedSet;
      
    } catch (e) {
      // Log the error
      debugPrint('[UsageNotifier::_loadBoundedApps] ERROR loading boundaries: $e');
      
      // Return empty set on error
      return {};
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Refresh the app list
  // Called when user pulls to refresh or manually triggers refresh
  // -------------------------------------------------------------------------
  Future<void> refresh() async {
    // Log entry into the method
    debugPrint('[UsageNotifier::refresh] User triggered refresh.');
    
    // Re-fetch the apps
    await _fetchApps();
    
    // Log completion
    debugPrint('[UsageNotifier::refresh] Refresh completed.');
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Set the selected category filter
  // Updates the filter and triggers UI rebuild
  // -------------------------------------------------------------------------
  void setCategory(AppCategory category) {
    // Log entry into the method
    debugPrint('[UsageNotifier::setCategory] Setting category to: ${category.displayName}');
    
    // Update state with new category
    state = state.copyWith(selectedCategory: category);
    
    // Log completion
    debugPrint('[UsageNotifier::setCategory] Category updated.');
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Set the selected time period
  // Updates the period and re-fetches data
  // -------------------------------------------------------------------------
  void setPeriod(UsageStatsPeriod period) {
    // Log entry into the method
    debugPrint('[UsageNotifier::setPeriod] Setting period to: ${period.displayName}');
    
    // Update state with new period
    state = state.copyWith(selectedPeriod: period);
    
    // Re-fetch data for the new period
    // In a real implementation, this would query different time ranges
    _fetchApps();
    
    // Log completion
    debugPrint('[UsageNotifier::setPeriod] Period updated, refreshing data.');
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Toggle boundary status for an app
  // Sets or removes a boundary on the specified app
  // -------------------------------------------------------------------------
  Future<void> toggleBoundary(String packageName) async {
    // Log entry into the method
    debugPrint('[UsageNotifier::toggleBoundary] Toggling boundary for: $packageName');
    
    try {
      // Find the app in the current list
      final appIndex = state.apps.indexWhere((app) => app.packageName == packageName);
      
      // Check if app was found
      if (appIndex == -1) {
        debugPrint('[UsageNotifier::toggleBoundary] App not found: $packageName');
        return;
      }
      
      // Get the current app
      final currentApp = state.apps[appIndex];
      
      // Toggle the boundary status
      final newBoundaryStatus = !currentApp.isBounded;
      
      // Log the change
      debugPrint('[UsageNotifier::toggleBoundary] Setting boundary to: $newBoundaryStatus');
      
      // Create updated app with new boundary status
      final updatedApp = currentApp.copyWith(isBounded: newBoundaryStatus);
      
      // Create new list with updated app
      final updatedApps = List<AppUsageModel>.from(state.apps);
      updatedApps[appIndex] = updatedApp;
      
      // Update state
      state = state.copyWith(apps: updatedApps);
      
      // Persist to Hive
      await _saveBoundedApps(updatedApps);
      
      // Log completion
      debugPrint('[UsageNotifier::toggleBoundary] Boundary toggled successfully.');
      
    } catch (e) {
      // Log the error
      debugPrint('[UsageNotifier::toggleBoundary] ERROR: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Save bounded apps to Hive storage
  // Persists the boundary configuration for app restart
  // -------------------------------------------------------------------------
  Future<void> _saveBoundedApps(List<AppUsageModel> apps) async {
    // Log entry into the method
    debugPrint('[UsageNotifier::_saveBoundedApps] Saving bounded apps to Hive.');
    
    try {
      // Get the list of bounded package names
      final boundedPackages = apps
          .where((app) => app.isBounded)
          .map((app) => app.packageName)
          .toList();
      
      // Log the count
      debugPrint('[UsageNotifier::_saveBoundedApps] Saving ${boundedPackages.length} bounded apps.');
      
      // Save to Hive
      await HiveService().put(
        boxName: HiveBoxNames.boundaries,
        key: 'bounded_packages',
        value: boundedPackages,
      );
      
      // Log completion
      debugPrint('[UsageNotifier::_saveBoundedApps] Saved successfully.');
      
    } catch (e) {
      // Log the error
      debugPrint('[UsageNotifier::_saveBoundedApps] ERROR saving boundaries: $e');
    }
  }
}

// ============================================================================
// USAGE PROVIDER
// ============================================================================
// The global Riverpod provider for usage state
// Access via: ref.watch(usageProvider) or ref.read(usageProvider.notifier)
// ============================================================================
final usageProvider = NotifierProvider<UsageNotifier, UsageState>(() {
  // Log provider creation
  debugPrint('[usageProvider] Creating UsageNotifier provider.');
  
  // Return new notifier instance
  return UsageNotifier();
});
