import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed Hive import
import 'package:shared_preferences/shared_preferences.dart';
// ...existing code...
import 'features/overlays/chase_overlay.dart';
import 'features/overlays/overlay_gate.dart';
import 'core/services/gate_task_manager.dart';
// ...existing code...
import 'core/theme/theme_provider.dart';

@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force blocklist and current_package for testing using SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  const testPackage = 'com.android.chrome';
  await prefs.setStringList('blockedApps', [testPackage]);
  await prefs.setString('current_package', testPackage);

  runApp(
    const ProviderScope(
      child: OverlayApp(),
    ),
  );
}

class OverlayApp extends ConsumerWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return FutureBuilder<bool>(
      future: _shouldShowGateOverlay(),
      builder: (context, snapshot) {
        return FutureBuilder<List<String>>(
          future: GateTaskManager.getPendingTasks(),
          builder: (context, taskSnap) {
            Widget overlayWidget;
            if (snapshot.data == true) {
              final List<String> pendingTasks = taskSnap.data ?? [];
              final bool forcedPlanning = pendingTasks.isEmpty;
              overlayWidget = OverlayGateScreen(
                pendingTasks: pendingTasks,
                forcedPlanning: forcedPlanning,
                onPlanningComplete: (newTasks) async {
                  await GateTaskManager.addTasks(newTasks);
                  Navigator.of(context).pop();
                },
                onTasksComplete: (completedTasks) async {
                  await GateTaskManager.completeAllTasks();
                  Navigator.of(context).pop();
                },
              );
            } else {
              overlayWidget = const ChaseOverlay();
            }
            return MaterialApp(
              title: 'IdleMan Overlay',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: theme.accent,
                scaffoldBackgroundColor: theme.background,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: theme.accent,
                  brightness: theme.isDark ? Brightness.dark : Brightness.light,
                ),
              ),
              home: overlayWidget,
            );
          },
        );
      },
    );
  }

  /// Checks if the Productivity Gate overlay should be shown.
  Future<bool> _shouldShowGateOverlay() async {
    // Read Productivity Gate enabled state, current package, and blocklist from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final bool gateEnabled = prefs.getBool('productivity_gate_enabled') ?? false;
    final String currentPackage = prefs.getString('current_package') ?? 'com.example.blocked';
    print('[DEBUG] Value in SharedPreferences for current_package: $currentPackage');
    final List<String> blocked = prefs.getStringList('blockedApps') ?? <String>[];
    final bool appBlocked = blocked.contains(currentPackage);
    print('[DEBUG] Productivity Gate enabled: $gateEnabled');
    print('[DEBUG] Current package: $currentPackage');
    print('[DEBUG] Blocked apps: $blocked');
    print('[DEBUG] App is blocked: $appBlocked');
    final pendingTasks = await GateTaskManager.getPendingTasks();
    print('[DEBUG] Pending tasks: $pendingTasks');
    return gateEnabled && appBlocked;
  }
}
