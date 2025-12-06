// ============================================================================
// IDLEMAN v16.0 - NOTIFICATION DIGEST PROVIDER
// ============================================================================
// File: lib/features/digest/providers/digest_provider.dart
// Purpose: State management for notification batching and delivery
// Philosophy: Reduce interruptions, deliver in calm moments
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:idleman/core/services/native_bridge.dart';

// ============================================================================
// DIGEST STATE
// ============================================================================
@immutable
class DigestState {
  final bool isEnabled;
  final bool hasNotificationAccess;
  final List<DigestSchedule> schedules;
  final List<DigestEntry> pendingNotifications;
  final List<DigestEntry> deliveredToday;
  final DateTime? lastDeliveryTime;
  final int totalBatchedToday;
  final int totalSilencedToday;
  final Set<String> excludedApps; // Apps exempt from digest (e.g., calls)

  const DigestState({
    this.isEnabled = false,
    this.hasNotificationAccess = false,
    this.schedules = const [],
    this.pendingNotifications = const [],
    this.deliveredToday = const [],
    this.lastDeliveryTime,
    this.totalBatchedToday = 0,
    this.totalSilencedToday = 0,
    this.excludedApps = const {'com.android.dialer', 'com.google.android.dialer'},
  });

  DigestState copyWith({
    bool? isEnabled,
    bool? hasNotificationAccess,
    List<DigestSchedule>? schedules,
    List<DigestEntry>? pendingNotifications,
    List<DigestEntry>? deliveredToday,
    DateTime? lastDeliveryTime,
    int? totalBatchedToday,
    int? totalSilencedToday,
    Set<String>? excludedApps,
  }) {
    return DigestState(
      isEnabled: isEnabled ?? this.isEnabled,
      hasNotificationAccess: hasNotificationAccess ?? this.hasNotificationAccess,
      schedules: schedules ?? this.schedules,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
      deliveredToday: deliveredToday ?? this.deliveredToday,
      lastDeliveryTime: lastDeliveryTime ?? this.lastDeliveryTime,
      totalBatchedToday: totalBatchedToday ?? this.totalBatchedToday,
      totalSilencedToday: totalSilencedToday ?? this.totalSilencedToday,
      excludedApps: excludedApps ?? this.excludedApps,
    );
  }
}

// ============================================================================
// DIGEST SCHEDULE
// ============================================================================
class DigestSchedule {
  final String id;
  final String label;
  final int hour;
  final int minute;
  final bool isEnabled;

  const DigestSchedule({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
  });

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  DateTime get nextDeliveryTime {
    final now = DateTime.now();
    var delivery = DateTime(now.year, now.month, now.day, hour, minute);
    if (delivery.isBefore(now)) {
      delivery = delivery.add(const Duration(days: 1));
    }
    return delivery;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'hour': hour,
        'minute': minute,
        'isEnabled': isEnabled,
      };

  factory DigestSchedule.fromJson(Map<String, dynamic> json) => DigestSchedule(
        id: json['id'] as String,
        label: json['label'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        isEnabled: json['isEnabled'] as bool? ?? true,
      );
}

// ============================================================================
// DIGEST ENTRY (Individual notification)
// ============================================================================
class DigestEntry {
  final String id;
  final String packageName;
  final String appName;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isGrouped;
  final int groupCount;
  final NotificationPriority priority;

  const DigestEntry({
    required this.id,
    required this.packageName,
    required this.appName,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isGrouped = false,
    this.groupCount = 1,
    this.priority = NotificationPriority.normal,
  });

  // Sanitize notification content (remove sensitive patterns)
  String get sanitizedBody {
    // Regex patterns to sanitize
    final patterns = [
      RegExp(r'\b\d{6}\b'), // OTP codes
      RegExp(r'password|passcode|pin|code', caseSensitive: false),
      RegExp(r'\$[\d,]+\.?\d*'), // Money amounts
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Card numbers
    ];

    String sanitized = body;
    for (final pattern in patterns) {
      sanitized = sanitized.replaceAll(pattern, '•••');
    }
    return sanitized;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'packageName': packageName,
        'appName': appName,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isGrouped': isGrouped,
        'groupCount': groupCount,
        'priority': priority.index,
      };

  factory DigestEntry.fromJson(Map<String, dynamic> json) => DigestEntry(
        id: json['id'] as String,
        packageName: json['packageName'] as String,
        appName: json['appName'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isGrouped: json['isGrouped'] as bool? ?? false,
        groupCount: json['groupCount'] as int? ?? 1,
        priority: NotificationPriority.values[json['priority'] as int? ?? 1],
      );
}

enum NotificationPriority { low, normal, high, urgent }

// ============================================================================
// DIGEST NOTIFIER
// ============================================================================
class DigestNotifier extends StateNotifier<DigestState> {
  final NativeBridge _nativeBridge;
  Box? _digestBox;

  DigestNotifier(this._nativeBridge) : super(const DigestState()) {
    debugPrint('[DigestNotifier] Initializing digest provider.');
    _initialize();
  }

  // -------------------------------------------------------------------------
  // INITIALIZATION
  // -------------------------------------------------------------------------
  Future<void> _initialize() async {
    debugPrint('[DigestNotifier::_initialize] Loading saved state.');

    try {
      _digestBox = await Hive.openBox('digest');

      // Load saved state
      final savedEnabled = _digestBox?.get('isEnabled', defaultValue: false) as bool;
      final savedSchedules = _digestBox?.get('schedules', defaultValue: <dynamic>[]) as List;

      // Check permission status
      final hasAccess = await _nativeBridge.hasNotificationListenerAccess();

      // Default schedules if none saved
      final schedules = savedSchedules.isEmpty
          ? _getDefaultSchedules()
          : savedSchedules
              .map((s) => DigestSchedule.fromJson(Map<String, dynamic>.from(s as Map)))
              .toList();

      state = state.copyWith(
        isEnabled: savedEnabled && hasAccess,
        hasNotificationAccess: hasAccess,
        schedules: schedules,
      );

      debugPrint('[DigestNotifier] Initialized: enabled=${state.isEnabled}, '
          'hasAccess=$hasAccess, schedules=${schedules.length}');

      // If enabled, start listening
      if (state.isEnabled) {
        await _startListening();
      }
    } catch (e) {
      debugPrint('[DigestNotifier::_initialize] Error: $e');
    }
  }

  List<DigestSchedule> _getDefaultSchedules() {
    return const [
      DigestSchedule(
        id: 'morning',
        label: 'Morning',
        hour: 8,
        minute: 0,
      ),
      DigestSchedule(
        id: 'noon',
        label: 'Midday',
        hour: 12,
        minute: 30,
      ),
      DigestSchedule(
        id: 'evening',
        label: 'Evening',
        hour: 18,
        minute: 0,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // ENABLE/DISABLE
  // -------------------------------------------------------------------------
  Future<void> setEnabled(bool enabled) async {
    debugPrint('[DigestNotifier::setEnabled] Setting enabled: $enabled');

    if (enabled && !state.hasNotificationAccess) {
      // Request permission first (opens settings)
      await _nativeBridge.requestNotificationListenerAccess();
      // Check if permission was granted
      final hasAccess = await _nativeBridge.hasNotificationListenerAccess();
      if (!hasAccess) {
        debugPrint('[DigestNotifier] Notification access not granted.');
        return;
      }
      state = state.copyWith(hasNotificationAccess: true);
    }

    state = state.copyWith(isEnabled: enabled);
    await _digestBox?.put('isEnabled', enabled);

    if (enabled) {
      await _startListening();
    } else {
      await _stopListening();
    }
  }

  Future<void> _startListening() async {
    debugPrint('[DigestNotifier::_startListening] Starting notification listener.');
    await _nativeBridge.startDigestMode();

    // Set up callback for incoming notifications
    _nativeBridge.onNotificationReceived = _handleIncomingNotification;
  }

  Future<void> _stopListening() async {
    debugPrint('[DigestNotifier::_stopListening] Stopping notification listener.');
    await _nativeBridge.stopDigestMode();
    _nativeBridge.onNotificationReceived = null;
  }

  // -------------------------------------------------------------------------
  // NOTIFICATION HANDLING
  // -------------------------------------------------------------------------
  void _handleIncomingNotification(Map<String, dynamic> notification) {
    debugPrint('[DigestNotifier::_handleIncomingNotification] Received: $notification');

    final packageName = notification['packageName'] as String? ?? '';

    // Check if excluded
    if (state.excludedApps.contains(packageName)) {
      debugPrint('[DigestNotifier] App excluded, letting through: $packageName');
      return;
    }

    // Create digest entry
    final entry = DigestEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      packageName: packageName,
      appName: notification['appName'] as String? ?? 'Unknown',
      title: notification['title'] as String? ?? '',
      body: notification['body'] as String? ?? '',
      timestamp: DateTime.now(),
      priority: _determinePriority(notification),
    );

    // Add to pending
    final pending = [...state.pendingNotifications, entry];

    // Group notifications from same app
    final grouped = _groupNotifications(pending);

    state = state.copyWith(
      pendingNotifications: grouped,
      totalBatchedToday: state.totalBatchedToday + 1,
    );

    debugPrint('[DigestNotifier] Added to pending. Total: ${grouped.length}');
  }

  NotificationPriority _determinePriority(Map<String, dynamic> notification) {
    final title = (notification['title'] as String? ?? '').toLowerCase();
    final body = (notification['body'] as String? ?? '').toLowerCase();

    // High priority patterns
    final urgentPatterns = ['urgent', 'emergency', 'asap', 'immediate'];
    final highPatterns = ['important', 'reminder', 'deadline', 'alert'];

    for (final pattern in urgentPatterns) {
      if (title.contains(pattern) || body.contains(pattern)) {
        return NotificationPriority.urgent;
      }
    }

    for (final pattern in highPatterns) {
      if (title.contains(pattern) || body.contains(pattern)) {
        return NotificationPriority.high;
      }
    }

    return NotificationPriority.normal;
  }

  List<DigestEntry> _groupNotifications(List<DigestEntry> entries) {
    // Group by app package
    final byApp = <String, List<DigestEntry>>{};
    for (final entry in entries) {
      byApp.putIfAbsent(entry.packageName, () => []).add(entry);
    }

    // Create grouped entries
    final grouped = <DigestEntry>[];
    for (final appEntries in byApp.values) {
      if (appEntries.length == 1) {
        grouped.add(appEntries.first);
      } else {
        // Create grouped entry
        final latest = appEntries.last;
        grouped.add(DigestEntry(
          id: latest.id,
          packageName: latest.packageName,
          appName: latest.appName,
          title: '${appEntries.length} notifications',
          body: appEntries.map((e) => e.title).take(3).join(' • '),
          timestamp: latest.timestamp,
          isGrouped: true,
          groupCount: appEntries.length,
          priority: appEntries
              .map((e) => e.priority)
              .reduce((a, b) => a.index > b.index ? a : b),
        ));
      }
    }

    // Sort by priority and time
    grouped.sort((a, b) {
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return b.timestamp.compareTo(a.timestamp);
    });

    return grouped;
  }

  // -------------------------------------------------------------------------
  // SCHEDULE MANAGEMENT
  // -------------------------------------------------------------------------
  Future<void> addSchedule(DigestSchedule schedule) async {
    debugPrint('[DigestNotifier::addSchedule] Adding: ${schedule.label}');

    final schedules = [...state.schedules, schedule];
    state = state.copyWith(schedules: schedules);

    await _saveSchedules();
  }

  Future<void> updateSchedule(DigestSchedule schedule) async {
    debugPrint('[DigestNotifier::updateSchedule] Updating: ${schedule.id}');

    final schedules = state.schedules
        .map((s) => s.id == schedule.id ? schedule : s)
        .toList();
    state = state.copyWith(schedules: schedules);

    await _saveSchedules();
  }

  Future<void> removeSchedule(String id) async {
    debugPrint('[DigestNotifier::removeSchedule] Removing: $id');

    final schedules = state.schedules.where((s) => s.id != id).toList();
    state = state.copyWith(schedules: schedules);

    await _saveSchedules();
  }

  Future<void> toggleSchedule(String id, bool enabled) async {
    debugPrint('[DigestNotifier::toggleSchedule] $id -> $enabled');

    final schedules = state.schedules.map((s) {
      if (s.id == id) {
        return DigestSchedule(
          id: s.id,
          label: s.label,
          hour: s.hour,
          minute: s.minute,
          isEnabled: enabled,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(schedules: schedules);
    await _saveSchedules();
  }

  Future<void> _saveSchedules() async {
    await _digestBox?.put(
      'schedules',
      state.schedules.map((s) => s.toJson()).toList(),
    );
  }

  // -------------------------------------------------------------------------
  // DELIVERY
  // -------------------------------------------------------------------------
  Future<void> deliverNow() async {
    debugPrint('[DigestNotifier::deliverNow] Delivering ${state.pendingNotifications.length} notifications.');

    if (state.pendingNotifications.isEmpty) {
      debugPrint('[DigestNotifier] No pending notifications.');
      return;
    }

    // Deliver through native bridge
    await _nativeBridge.deliverDigest();

    // Move to delivered
    state = state.copyWith(
      pendingNotifications: [],
      deliveredToday: [...state.deliveredToday, ...state.pendingNotifications],
      lastDeliveryTime: DateTime.now(),
    );

    debugPrint('[DigestNotifier] Delivery complete.');
  }

  Future<void> clearPending() async {
    debugPrint('[DigestNotifier::clearPending] Clearing pending notifications.');

    state = state.copyWith(
      pendingNotifications: [],
      totalSilencedToday: state.totalSilencedToday + state.pendingNotifications.length,
    );
  }

  // -------------------------------------------------------------------------
  // EXCLUDED APPS
  // -------------------------------------------------------------------------
  void addExcludedApp(String packageName) {
    debugPrint('[DigestNotifier::addExcludedApp] Adding: $packageName');

    final excluded = {...state.excludedApps, packageName};
    state = state.copyWith(excludedApps: excluded);
  }

  void removeExcludedApp(String packageName) {
    debugPrint('[DigestNotifier::removeExcludedApp] Removing: $packageName');

    final excluded = state.excludedApps.where((p) => p != packageName).toSet();
    state = state.copyWith(excludedApps: excluded);
  }

  // -------------------------------------------------------------------------
  // STATS
  // -------------------------------------------------------------------------
  int get pendingCount => state.pendingNotifications.length;

  String? get nextDeliveryTimeString {
    final enabledSchedules = state.schedules.where((s) => s.isEnabled).toList();
    if (enabledSchedules.isEmpty) return null;

    final nextTimes = enabledSchedules.map((s) => s.nextDeliveryTime);
    final soonest = nextTimes.reduce((a, b) => a.isBefore(b) ? a : b);

    final diff = soonest.difference(DateTime.now());
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    } else {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
  }
}

// ============================================================================
// PROVIDER
// ============================================================================
final digestProvider = StateNotifierProvider<DigestNotifier, DigestState>((ref) {
  final nativeBridge = ref.watch(nativeBridgeProvider);
  return DigestNotifier(nativeBridge);
});

// Convenience providers
final pendingNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(digestProvider).pendingNotifications.length;
});

final nextDigestTimeProvider = Provider<String?>((ref) {
  return ref.watch(digestProvider.notifier).nextDeliveryTimeString;
});
