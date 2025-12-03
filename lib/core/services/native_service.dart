import 'package:flutter/services.dart';

/// Service for communicating with native Android layer
class NativeService {
  static const MethodChannel _channel = MethodChannel('com.idleman/native');
  static const MethodChannel _monitorChannel =
      MethodChannel('com.idleman/app_monitor');

  /// Check if accessibility service is enabled
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final result =
          await _channel.invokeMethod('checkAccessibilityPermission');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  /// Request accessibility permission
  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      // Handle error
    }
  }

  /// Check if overlay permission is granted
  static Future<bool> checkOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('checkOverlayPermission');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  /// Request overlay permission
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      // Handle error
    }
  }

  /// Update blocked apps list
  static Future<bool> updateBlockedApps(List<String> packages) async {
    try {
      final result = await _channel.invokeMethod('updateBlockedApps', {
        'packages': packages,
      });
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  /// Get list of installed apps
  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      final apps = (result as List).cast<Map<dynamic, dynamic>>();
      return apps.map((app) {
        return {
          'packageName': app['packageName'] as String,
          'appName': app['appName'] as String,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Set up listener for app blocked events
  static void setAppBlockedListener(
      Function(String packageName, int timestamp) callback) {
    _monitorChannel.setMethodCallHandler((call) async {
      if (call.method == 'appBlocked') {
        final packageName = call.arguments['packageName'] as String;
        final timestamp = call.arguments['timestamp'] as int;
        callback(packageName, timestamp);
      }
    });
  }
}
