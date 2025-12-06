// ============================================================================
// IDLEMAN v16.0 - NATIVE BRIDGE SERVICE
// ============================================================================
// File: lib/core/services/native_bridge.dart
// Purpose: MethodChannel communication between Flutter and Kotlin Native
// Philosophy: Bridge the gap between UI elegance and system-level persistence
// ============================================================================

// Import Flutter foundation for debugPrint
import 'package:flutter/foundation.dart';

// Import Flutter services for MethodChannel
import 'package:flutter/services.dart';

// Import Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// NATIVE BRIDGE SERVICE
// ============================================================================
// Singleton service that manages all Flutter <-> Kotlin communication
// Provides typed methods for each native capability
// ============================================================================
class NativeBridge {
  // -------------------------------------------------------------------------
  // Private constructor for singleton pattern
  // -------------------------------------------------------------------------
  NativeBridge._internal();

  // -------------------------------------------------------------------------
  // Singleton instance - only one NativeBridge exists in the app
  // -------------------------------------------------------------------------
  static final NativeBridge _instance = NativeBridge._internal();

  // -------------------------------------------------------------------------
  // Factory constructor returns the singleton instance
  // -------------------------------------------------------------------------
  factory NativeBridge() {
    debugPrint('[NativeBridge::factory] Returning singleton instance.');
    return _instance;
  }

  // -------------------------------------------------------------------------
  // CHANNEL NAMES - Constants for all MethodChannel identifiers
  // -------------------------------------------------------------------------
  static const String _mainChannel = 'com.idleman.app/main';
  static const String _usageChannel = 'com.idleman.app/usage';
  static const String _overlayChannel = 'com.idleman.app/overlay';
  static const String _accessibilityChannel = 'com.idleman.app/accessibility';
  static const String _sensorChannel = 'com.idleman.app/sensors';
  static const String _notificationChannel = 'com.idleman.app/notifications';

  // -------------------------------------------------------------------------
  // METHOD CHANNELS - Instances for each communication channel
  // -------------------------------------------------------------------------
  final MethodChannel _main = const MethodChannel(_mainChannel);
  final MethodChannel _usage = const MethodChannel(_usageChannel);
  final MethodChannel _overlay = const MethodChannel(_overlayChannel);
  final MethodChannel _accessibility = const MethodChannel(_accessibilityChannel);
  final MethodChannel _sensors = const MethodChannel(_sensorChannel);
  final MethodChannel _notifications = const MethodChannel(_notificationChannel);

  // -------------------------------------------------------------------------
  // INITIALIZATION FLAG
  // -------------------------------------------------------------------------
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // -------------------------------------------------------------------------
  // INITIALIZE - Setup method call handlers for incoming native calls
  // -------------------------------------------------------------------------
  Future<void> initialize() async {
    debugPrint('[NativeBridge::initialize] ================================');
    debugPrint('[NativeBridge::initialize] Starting NativeBridge setup...');
    debugPrint('[NativeBridge::initialize] ================================');

    if (_isInitialized) {
      debugPrint('[NativeBridge::initialize] Already initialized. Skipping.');
      return;
    }

    // Setup handler for incoming calls from native side
    _main.setMethodCallHandler(_handleMainMethodCall);
    _accessibility.setMethodCallHandler(_handleAccessibilityMethodCall);
    _sensors.setMethodCallHandler(_handleSensorMethodCall);

    _isInitialized = true;

    debugPrint('[NativeBridge::initialize] ================================');
    debugPrint('[NativeBridge::initialize] NativeBridge initialized!');
    debugPrint('[NativeBridge::initialize] ================================');
  }

  // -------------------------------------------------------------------------
  // HANDLER: Main channel incoming calls
  // -------------------------------------------------------------------------
  Future<dynamic> _handleMainMethodCall(MethodCall call) async {
    debugPrint('[NativeBridge::_handleMainMethodCall] Received: ${call.method}');
    
    switch (call.method) {
      case 'onServiceStarted':
        debugPrint('[NativeBridge] AccessibilityService started notification received.');
        _onServiceStartedCallback?.call();
        return true;
      case 'onServiceStopped':
        debugPrint('[NativeBridge] AccessibilityService stopped notification received.');
        _onServiceStoppedCallback?.call();
        return true;
      default:
        debugPrint('[NativeBridge] Unknown method: ${call.method}');
        throw PlatformException(code: 'UNKNOWN_METHOD', message: call.method);
    }
  }

  // -------------------------------------------------------------------------
  // HANDLER: Accessibility events from native
  // -------------------------------------------------------------------------
  Future<dynamic> _handleAccessibilityMethodCall(MethodCall call) async {
    debugPrint('[NativeBridge::_handleAccessibilityMethodCall] Received: ${call.method}');
    
    switch (call.method) {
      case 'onBoundedAppOpened':
        final String packageName = call.arguments['packageName'];
        final String appName = call.arguments['appName'] ?? packageName;
        debugPrint('[NativeBridge] Bounded app opened: $appName ($packageName)');
        _onBoundedAppOpenedCallback?.call(packageName, appName);
        return true;
      case 'onAppClosed':
        final String packageName = call.arguments['packageName'];
        debugPrint('[NativeBridge] App closed: $packageName');
        _onAppClosedCallback?.call(packageName);
        return true;
      default:
        debugPrint('[NativeBridge] Unknown accessibility method: ${call.method}');
        throw PlatformException(code: 'UNKNOWN_METHOD', message: call.method);
    }
  }

  // -------------------------------------------------------------------------
  // HANDLER: Sensor events from native
  // -------------------------------------------------------------------------
  Future<dynamic> _handleSensorMethodCall(MethodCall call) async {
    debugPrint('[NativeBridge::_handleSensorMethodCall] Received: ${call.method}');
    
    switch (call.method) {
      case 'onStepDetected':
        final bool isValid = call.arguments['isValid'] ?? true;
        final int totalSteps = call.arguments['totalSteps'] ?? 0;
        debugPrint('[NativeBridge] Step detected - Valid: $isValid, Total: $totalSteps');
        _onStepDetectedCallback?.call(isValid, totalSteps);
        return true;
      case 'onJerkDetected':
        debugPrint('[NativeBridge] Jerk detected - Step invalidated!');
        _onJerkDetectedCallback?.call();
        return true;
      default:
        debugPrint('[NativeBridge] Unknown sensor method: ${call.method}');
        throw PlatformException(code: 'UNKNOWN_METHOD', message: call.method);
    }
  }

  // =========================================================================
  // CALLBACKS - Set by Flutter side to handle native events
  // =========================================================================
  Function()? _onServiceStartedCallback;
  Function()? _onServiceStoppedCallback;
  Function(String packageName, String appName)? _onBoundedAppOpenedCallback;
  Function(String packageName)? _onAppClosedCallback;
  Function(bool isValid, int totalSteps)? _onStepDetectedCallback;
  Function()? _onJerkDetectedCallback;

  void setOnServiceStarted(Function() callback) {
    _onServiceStartedCallback = callback;
  }

  void setOnServiceStopped(Function() callback) {
    _onServiceStoppedCallback = callback;
  }

  void setOnBoundedAppOpened(Function(String, String) callback) {
    _onBoundedAppOpenedCallback = callback;
  }

  void setOnAppClosed(Function(String) callback) {
    _onAppClosedCallback = callback;
  }

  void setOnStepDetected(Function(bool, int) callback) {
    _onStepDetectedCallback = callback;
  }

  void setOnJerkDetected(Function() callback) {
    _onJerkDetectedCallback = callback;
  }

  // =========================================================================
  // USAGE STATS METHODS
  // =========================================================================

  // -------------------------------------------------------------------------
  // Get usage stats for a time period
  // Returns list of app usage data from UsageStatsManager
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getUsageStats({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    debugPrint('[NativeBridge::getUsageStats] Fetching usage stats...');
    debugPrint('[NativeBridge::getUsageStats] Start: $startTime, End: $endTime');

    try {
      final result = await _usage.invokeMethod('getUsageStats', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });

      debugPrint('[NativeBridge::getUsageStats] Received ${result?.length ?? 0} apps.');

      if (result == null) return [];

      return List<Map<String, dynamic>>.from(
        (result as List).map((item) => Map<String, dynamic>.from(item)),
      );
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::getUsageStats] ERROR: ${e.message}');
      return [];
    }
  }

  // -------------------------------------------------------------------------
  // Check if usage stats permission is granted
  // -------------------------------------------------------------------------
  Future<bool> hasUsageStatsPermission() async {
    debugPrint('[NativeBridge::hasUsageStatsPermission] Checking permission...');

    try {
      final result = await _usage.invokeMethod('hasUsageStatsPermission');
      debugPrint('[NativeBridge::hasUsageStatsPermission] Result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::hasUsageStatsPermission] ERROR: ${e.message}');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Request usage stats permission (opens system settings)
  // -------------------------------------------------------------------------
  Future<void> requestUsageStatsPermission() async {
    debugPrint('[NativeBridge::requestUsageStatsPermission] Opening settings...');

    try {
      await _usage.invokeMethod('requestUsageStatsPermission');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::requestUsageStatsPermission] ERROR: ${e.message}');
    }
  }

  // =========================================================================
  // ACCESSIBILITY SERVICE METHODS
  // =========================================================================

  // -------------------------------------------------------------------------
  // Check if accessibility service is enabled
  // -------------------------------------------------------------------------
  Future<bool> isAccessibilityServiceEnabled() async {
    debugPrint('[NativeBridge::isAccessibilityServiceEnabled] Checking...');

    try {
      final result = await _accessibility.invokeMethod('isServiceEnabled');
      debugPrint('[NativeBridge::isAccessibilityServiceEnabled] Result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::isAccessibilityServiceEnabled] ERROR: ${e.message}');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Open accessibility settings to enable the service
  // -------------------------------------------------------------------------
  Future<void> openAccessibilitySettings() async {
    debugPrint('[NativeBridge::openAccessibilitySettings] Opening settings...');

    try {
      await _accessibility.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::openAccessibilitySettings] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Update the list of bounded apps in native service
  // -------------------------------------------------------------------------
  Future<void> updateBoundedApps(List<String> packageNames) async {
    debugPrint('[NativeBridge::updateBoundedApps] Updating ${packageNames.length} apps...');

    try {
      await _accessibility.invokeMethod('updateBoundedApps', {
        'packages': packageNames,
      });
      debugPrint('[NativeBridge::updateBoundedApps] Update sent successfully.');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::updateBoundedApps] ERROR: ${e.message}');
    }
  }

  // =========================================================================
  // OVERLAY METHODS
  // =========================================================================

  // -------------------------------------------------------------------------
  // Check if overlay permission is granted
  // -------------------------------------------------------------------------
  Future<bool> hasOverlayPermission() async {
    debugPrint('[NativeBridge::hasOverlayPermission] Checking permission...');

    try {
      final result = await _overlay.invokeMethod('hasOverlayPermission');
      debugPrint('[NativeBridge::hasOverlayPermission] Result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::hasOverlayPermission] ERROR: ${e.message}');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Request overlay permission (opens system settings)
  // -------------------------------------------------------------------------
  Future<void> requestOverlayPermission() async {
    debugPrint('[NativeBridge::requestOverlayPermission] Opening settings...');

    try {
      await _overlay.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::requestOverlayPermission] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Show the Intent Check overlay (Level 1)
  // -------------------------------------------------------------------------
  Future<void> showIntentOverlay({
    required String packageName,
    required String appName,
  }) async {
    debugPrint('[NativeBridge::showIntentOverlay] Showing for: $appName');

    try {
      await _overlay.invokeMethod('showIntentOverlay', {
        'packageName': packageName,
        'appName': appName,
      });
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::showIntentOverlay] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Show the Ghost Timer overlay
  // -------------------------------------------------------------------------
  Future<void> showGhostTimer({
    required int durationMinutes,
    required String appName,
  }) async {
    debugPrint('[NativeBridge::showGhostTimer] Starting ${durationMinutes}m timer for: $appName');

    try {
      await _overlay.invokeMethod('showGhostTimer', {
        'durationMinutes': durationMinutes,
        'appName': appName,
      });
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::showGhostTimer] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Dismiss the Ghost Timer overlay
  // -------------------------------------------------------------------------
  Future<void> dismissGhostTimer() async {
    debugPrint('[NativeBridge::dismissGhostTimer] Dismissing timer...');

    try {
      await _overlay.invokeMethod('dismissGhostTimer');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::dismissGhostTimer] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Show the Hard Boundary overlay (Level 3)
  // -------------------------------------------------------------------------
  Future<void> showHardBoundary({
    required String packageName,
    required String appName,
  }) async {
    debugPrint('[NativeBridge::showHardBoundary] Blocking: $appName');

    try {
      await _overlay.invokeMethod('showHardBoundary', {
        'packageName': packageName,
        'appName': appName,
      });
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::showHardBoundary] ERROR: ${e.message}');
    }
  }

  // =========================================================================
  // SENSOR METHODS (Pedometer)
  // =========================================================================

  // -------------------------------------------------------------------------
  // Start step detection with jerk filter
  // -------------------------------------------------------------------------
  Future<void> startStepDetection({
    required int targetSteps,
  }) async {
    debugPrint('[NativeBridge::startStepDetection] Starting with target: $targetSteps steps');

    try {
      await _sensors.invokeMethod('startStepDetection', {
        'targetSteps': targetSteps,
      });
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::startStepDetection] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Stop step detection
  // -------------------------------------------------------------------------
  Future<void> stopStepDetection() async {
    debugPrint('[NativeBridge::stopStepDetection] Stopping detection...');

    try {
      await _sensors.invokeMethod('stopStepDetection');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::stopStepDetection] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Get current step count
  // -------------------------------------------------------------------------
  Future<int> getCurrentStepCount() async {
    debugPrint('[NativeBridge::getCurrentStepCount] Getting step count...');

    try {
      final result = await _sensors.invokeMethod('getCurrentStepCount');
      debugPrint('[NativeBridge::getCurrentStepCount] Steps: $result');
      return result ?? 0;
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::getCurrentStepCount] ERROR: ${e.message}');
      return 0;
    }
  }

  // =========================================================================
  // NOTIFICATION METHODS
  // =========================================================================

  // -------------------------------------------------------------------------
  // Check if notification listener permission is granted
  // -------------------------------------------------------------------------
  Future<bool> hasNotificationListenerPermission() async {
    debugPrint('[NativeBridge::hasNotificationListenerPermission] Checking...');

    try {
      final result = await _notifications.invokeMethod('hasPermission');
      debugPrint('[NativeBridge::hasNotificationListenerPermission] Result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::hasNotificationListenerPermission] ERROR: ${e.message}');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Request notification listener permission
  // -------------------------------------------------------------------------
  Future<void> requestNotificationListenerPermission() async {
    debugPrint('[NativeBridge::requestNotificationListenerPermission] Opening settings...');

    try {
      await _notifications.invokeMethod('requestPermission');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::requestNotificationListenerPermission] ERROR: ${e.message}');
    }
  }

  // =========================================================================
  // TIME ANTI-CHEAT
  // =========================================================================

  // -------------------------------------------------------------------------
  // Validate system time against NTP
  // Returns offset in milliseconds (negative = behind, positive = ahead)
  // -------------------------------------------------------------------------
  Future<int?> validateSystemTime() async {
    debugPrint('[NativeBridge::validateSystemTime] Checking NTP time...');

    try {
      final result = await _main.invokeMethod('validateSystemTime');
      debugPrint('[NativeBridge::validateSystemTime] Offset: ${result}ms');
      return result;
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::validateSystemTime] ERROR: ${e.message}');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Check if time tampering is detected
  // Returns true if system time deviates more than 60s from NTP
  // -------------------------------------------------------------------------
  Future<bool> isTimeTampered() async {
    debugPrint('[NativeBridge::isTimeTampered] Checking for tampering...');

    try {
      final offset = await validateSystemTime();
      if (offset == null) return false; // Can't validate, assume OK
      
      final isTampered = offset.abs() > 60000; // 60 seconds threshold
      debugPrint('[NativeBridge::isTimeTampered] Result: $isTampered');
      return isTampered;
    } catch (e) {
      debugPrint('[NativeBridge::isTimeTampered] ERROR: $e');
      return false;
    }
  }

  // =========================================================================
  // HYDRA PROTOCOL (Service Resilience)
  // =========================================================================

  // -------------------------------------------------------------------------
  // Show notification when service goes down
  // -------------------------------------------------------------------------
  Future<void> showServiceDownNotification() async {
    debugPrint('[NativeBridge::showServiceDownNotification] Showing notification...');

    try {
      await _main.invokeMethod('showServiceDownNotification');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::showServiceDownNotification] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Request battery optimization exclusion (keep alive)
  // -------------------------------------------------------------------------
  Future<void> requestBatteryOptimizationExclusion() async {
    debugPrint('[NativeBridge::requestBatteryOptimizationExclusion] Requesting...');

    try {
      await _main.invokeMethod('requestIgnoreBatteryOptimization');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::requestBatteryOptimizationExclusion] ERROR: ${e.message}');
    }
  }

  // =========================================================================
  // DIGEST ENGINE METHODS (Notification Batching)
  // =========================================================================

  // -------------------------------------------------------------------------
  // Check if notification listener access is granted
  // -------------------------------------------------------------------------
  Future<bool> hasNotificationListenerAccess() async {
    debugPrint('[NativeBridge::hasNotificationListenerAccess] Checking...');

    try {
      final result = await _notifications.invokeMethod('hasListenerAccess');
      debugPrint('[NativeBridge::hasNotificationListenerAccess] Result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::hasNotificationListenerAccess] ERROR: ${e.message}');
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Request notification listener access (opens settings)
  // -------------------------------------------------------------------------
  Future<void> requestNotificationListenerAccess() async {
    debugPrint('[NativeBridge::requestNotificationListenerAccess] Opening settings...');

    try {
      await _notifications.invokeMethod('requestListenerAccess');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::requestNotificationListenerAccess] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Start digest mode (intercept and batch notifications)
  // -------------------------------------------------------------------------
  Future<void> startDigestMode() async {
    debugPrint('[NativeBridge::startDigestMode] Starting digest mode...');

    try {
      await _notifications.invokeMethod('startDigestMode');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::startDigestMode] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Stop digest mode
  // -------------------------------------------------------------------------
  Future<void> stopDigestMode() async {
    debugPrint('[NativeBridge::stopDigestMode] Stopping digest mode...');

    try {
      await _notifications.invokeMethod('stopDigestMode');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::stopDigestMode] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Deliver batched notifications
  // -------------------------------------------------------------------------
  Future<void> deliverDigest() async {
    debugPrint('[NativeBridge::deliverDigest] Delivering digest...');

    try {
      await _notifications.invokeMethod('deliverDigest');
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::deliverDigest] ERROR: ${e.message}');
    }
  }

  // -------------------------------------------------------------------------
  // Callback for received notifications
  // -------------------------------------------------------------------------
  Function(Map<String, dynamic>)? _onNotificationReceivedCallback;

  set onNotificationReceived(Function(Map<String, dynamic>)? callback) {
    _onNotificationReceivedCallback = callback;
    // Setup method call handler for notification events
    _notifications.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationReceived' && _onNotificationReceivedCallback != null) {
        final data = Map<String, dynamic>.from(call.arguments);
        _onNotificationReceivedCallback!(data);
      }
      return null;
    });
  }

  // -------------------------------------------------------------------------
  // Show foreground notification (Hydra Protocol)
  // -------------------------------------------------------------------------
  Future<void> showForegroundNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('[NativeBridge::showForegroundNotification] Showing: $title');

    try {
      await _notifications.invokeMethod('showForegroundNotification', {
        'title': title,
        'body': body,
      });
    } on PlatformException catch (e) {
      debugPrint('[NativeBridge::showForegroundNotification] ERROR: ${e.message}');
    }
  }
}

// ============================================================================
// NATIVE BRIDGE PROVIDER
// ============================================================================
// Riverpod provider for NativeBridge singleton
// Use ref.watch(nativeBridgeProvider) to access NativeBridge instance
// ============================================================================
final nativeBridgeProvider = Provider<NativeBridge>((ref) {
  debugPrint('[nativeBridgeProvider] Creating NativeBridge singleton provider.');
  return NativeBridge();
});
