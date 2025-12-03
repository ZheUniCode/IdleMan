import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/native_service.dart';

/// Model for a blocked app
class BlockedApp {
  final String packageName;
  final String appName;
  final bool isBlocked;

  BlockedApp({
    required this.packageName,
    required this.appName,
    required this.isBlocked,
  });

  BlockedApp copyWith({
    String? packageName,
    String? appName,
    bool? isBlocked,
  }) {
    return BlockedApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

/// Notifier for managing blocked apps
class BlocklistNotifier extends StateNotifier<List<BlockedApp>> {
  static const String _boxName = 'blocklistBox';
  static const String _blocklistKey = 'blockedApps';

  BlocklistNotifier() : super([]) {
    _loadBlocklist();
  }

  /// Load blocklist from Hive and merge with installed apps
  Future<void> _loadBlocklist() async {
    try {
      final box = await Hive.openBox(_boxName);
      final savedPackages =
          (box.get(_blocklistKey, defaultValue: <String>[]) as List)
              .cast<String>()
              .toSet();

      // Get installed apps from native
      final installedApps = await NativeService.getInstalledApps();

      state = installedApps.map((app) {
        return BlockedApp(
          packageName: app['packageName']!,
          appName: app['appName']!,
          isBlocked: savedPackages.contains(app['packageName']),
        );
      }).toList();

      // Update native layer
      await _syncWithNative();
    } catch (e) {
      state = [];
    }
  }

  /// Toggle block status for an app
  Future<void> toggleApp(String packageName) async {
    state = state.map((app) {
      if (app.packageName == packageName) {
        return app.copyWith(isBlocked: !app.isBlocked);
      }
      return app;
    }).toList();

    await _saveBlocklist();
    await _syncWithNative();
  }

  /// Add an app to blocklist
  Future<void> blockApp(String packageName) async {
    state = state.map((app) {
      if (app.packageName == packageName) {
        return app.copyWith(isBlocked: true);
      }
      return app;
    }).toList();

    await _saveBlocklist();
    await _syncWithNative();
  }

  /// Remove an app from blocklist
  Future<void> unblockApp(String packageName) async {
    state = state.map((app) {
      if (app.packageName == packageName) {
        return app.copyWith(isBlocked: false);
      }
      return app;
    }).toList();

    await _saveBlocklist();
    await _syncWithNative();
  }

  /// Get list of blocked package names
  List<String> getBlockedPackages() {
    return state
        .where((app) => app.isBlocked)
        .map((app) => app.packageName)
        .toList();
  }

  /// Save blocklist to Hive
  Future<void> _saveBlocklist() async {
    try {
      final box = await Hive.openBox(_boxName);
      final blockedPackages = getBlockedPackages();
      await box.put(_blocklistKey, blockedPackages);
    } catch (e) {
      // Handle error
    }
  }

  /// Sync blocklist with native layer
  Future<void> _syncWithNative() async {
    final blockedPackages = getBlockedPackages();
    await NativeService.updateBlockedApps(blockedPackages);
  }

  /// Reload apps list
  Future<void> reload() async {
    await _loadBlocklist();
  }
}

/// Provider for blocklist
final blocklistProvider =
    StateNotifierProvider<BlocklistNotifier, List<BlockedApp>>((ref) {
  return BlocklistNotifier();
});
