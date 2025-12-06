// ============================================================================
// IDLEMAN v16.0 - BACKGROUND SERVICE
// ============================================================================
// File: lib/core/services/background_service.dart
// Purpose: Handle background tasks via WorkManager (Hydra Protocol)
// Philosophy: Silent resilience - keeping the garden alive
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:idleman/core/services/native_bridge.dart';

// Task names
const String taskCheckServiceHealth = 'com.idleman.task.checkServiceHealth';

// ============================================================================
// CALLBACK DISPATCHER
// ============================================================================
// This function runs in a separate isolate when a background task is triggered
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[BackgroundService] Executing task: $task');

    switch (task) {
      case taskCheckServiceHealth:
        return await _handleServiceHealthCheck();
      default:
        return Future.value(true);
    }
  });
}

// ---------------------------------------------------------------------------
// HANDLER: Service Health Check
// ---------------------------------------------------------------------------
Future<bool> _handleServiceHealthCheck() async {
  try {
    debugPrint('[BackgroundService] Checking accessibility service status...');
    
    // We need to create a new instance of NativeBridge since we are in a new isolate
    // Note: Riverpod providers are not available here directly
    final bridge = NativeBridge();
    
    final isEnabled = await bridge.isAccessibilityServiceEnabled();
    debugPrint('[BackgroundService] Service enabled: $isEnabled');
    
    if (!isEnabled) {
      // If service is down, show a high-priority notification
      // This uses the native bridge's notification capability
      await bridge.showForegroundNotification(
        title: 'IdleMan Needs Attention',
        body: 'The boundary service has stopped. Tap to reactivate.',
      );
      
      // In a full implementation, we might also try to restart it or log the event
    }
    
    return true;
  } catch (e) {
    debugPrint('[BackgroundService] Error in health check: $e');
    return false;
  }
}

// ============================================================================
// BACKGROUND SERVICE MANAGER
// ============================================================================
class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  bool _isInitialized = false;

  // -------------------------------------------------------------------------
  // INITIALIZE
  // -------------------------------------------------------------------------
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('[BackgroundService] Initializing WorkManager...');
    
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode, // True in debug for easier testing
      );
      
      _isInitialized = true;
      debugPrint('[BackgroundService] WorkManager initialized.');
      
      // Register periodic task
      _registerPeriodicTasks();
    } catch (e) {
      debugPrint('[BackgroundService] Failed to initialize: $e');
    }
  }

  // -------------------------------------------------------------------------
  // REGISTER TASKS
  // -------------------------------------------------------------------------
  void _registerPeriodicTasks() {
    debugPrint('[BackgroundService] Registering periodic tasks...');
    
    // Check service health every 15 minutes (minimum allowed by Android)
    Workmanager().registerPeriodicTask(
      "idleman_health_check",
      taskCheckServiceHealth,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        requiresBatteryNotLow: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
