import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ...existing code...
import 'features/overlays/chase_overlay.dart';
import 'features/overlays/overlay_gate.dart';
import 'core/services/gate_task_manager.dart';
// ...existing code...
import 'core/theme/theme_provider.dart';

@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

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
    // Read Productivity Gate enabled state from Hive
    final settingsBox = await Hive.openBox('settings');
    final bool gateEnabled = settingsBox.get('productivity_gate_enabled', defaultValue: false);
    final String currentPackage = settingsBox.get('current_package', defaultValue: 'com.example.blocked'); // TODO: Replace with real package detection
    final blocklistBox = await Hive.openBox('blocklistBox');
    final List blocked = blocklistBox.get('blockedApps', defaultValue: <String>[]);
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
