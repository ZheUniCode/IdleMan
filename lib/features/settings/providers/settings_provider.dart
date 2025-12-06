// ============================================================================
// IDLEMAN v16.0 - SETTINGS PROVIDER
// ============================================================================
// File: lib/features/settings/providers/settings_provider.dart
// Purpose: Riverpod state management for app settings
// Philosophy: User preferences stored locally, respecting privacy
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/services/hive_service.dart';

// ============================================================================
// DIGEST SCHEDULE - When to deliver batched notifications
// ============================================================================
class DigestSchedule {
  final int hour;
  final int minute;
  final bool isEnabled;

  const DigestSchedule({
    required this.hour,
    required this.minute,
    this.isEnabled = true,
  });

  String get displayTime {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  Map<String, dynamic> toMap() => {
    'hour': hour,
    'minute': minute,
    'isEnabled': isEnabled,
  };

  factory DigestSchedule.fromMap(Map<String, dynamic> map) => DigestSchedule(
    hour: map['hour'] ?? 12,
    minute: map['minute'] ?? 0,
    isEnabled: map['isEnabled'] ?? true,
  );
}

// ============================================================================
// SETTINGS STATE
// ============================================================================
class SettingsState {
  // -------------------------------------------------------------------------
  // STRICT MODE - When enabled, Level 3 blocks are unbypassable
  // -------------------------------------------------------------------------
  final bool strictModeEnabled;

  // -------------------------------------------------------------------------
  // NOTIFICATION DIGEST - Batch and sanitize notifications
  // -------------------------------------------------------------------------
  final bool digestEnabled;
  final List<DigestSchedule> digestSchedules;

  // -------------------------------------------------------------------------
  // HYDRA PROTOCOL - Keep service alive
  // -------------------------------------------------------------------------
  final bool hydraProtocolEnabled;

  // -------------------------------------------------------------------------
  // ONBOARDING - Has user completed setup?
  // -------------------------------------------------------------------------
  final bool onboardingComplete;

  // -------------------------------------------------------------------------
  // PERMISSIONS STATUS
  // -------------------------------------------------------------------------
  final bool hasUsageStatsPermission;
  final bool hasAccessibilityPermission;
  final bool hasOverlayPermission;
  final bool hasNotificationPermission;

  // -------------------------------------------------------------------------
  // TIME RECLAIMED - Positive metric tracking
  // -------------------------------------------------------------------------
  final int timeReclaimedMinutes;
  final int currentStreak;
  final int longestStreak;

  // -------------------------------------------------------------------------
  // LOADING STATE
  // -------------------------------------------------------------------------
  final bool isLoading;

  const SettingsState({
    this.strictModeEnabled = false,
    this.digestEnabled = true,
    this.digestSchedules = const [
      DigestSchedule(hour: 13, minute: 0),  // 1 PM
      DigestSchedule(hour: 18, minute: 0),  // 6 PM
    ],
    this.hydraProtocolEnabled = true,
    this.onboardingComplete = false,
    this.hasUsageStatsPermission = false,
    this.hasAccessibilityPermission = false,
    this.hasOverlayPermission = false,
    this.hasNotificationPermission = false,
    this.timeReclaimedMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isLoading = true,
  });

  // -------------------------------------------------------------------------
  // GETTER: All required permissions granted
  // -------------------------------------------------------------------------
  bool get hasAllRequiredPermissions =>
      hasUsageStatsPermission &&
      hasAccessibilityPermission &&
      hasOverlayPermission;

  // -------------------------------------------------------------------------
  // COPY WITH
  // -------------------------------------------------------------------------
  SettingsState copyWith({
    bool? strictModeEnabled,
    bool? digestEnabled,
    List<DigestSchedule>? digestSchedules,
    bool? hydraProtocolEnabled,
    bool? onboardingComplete,
    bool? hasUsageStatsPermission,
    bool? hasAccessibilityPermission,
    bool? hasOverlayPermission,
    bool? hasNotificationPermission,
    int? timeReclaimedMinutes,
    int? currentStreak,
    int? longestStreak,
    bool? isLoading,
  }) {
    return SettingsState(
      strictModeEnabled: strictModeEnabled ?? this.strictModeEnabled,
      digestEnabled: digestEnabled ?? this.digestEnabled,
      digestSchedules: digestSchedules ?? this.digestSchedules,
      hydraProtocolEnabled: hydraProtocolEnabled ?? this.hydraProtocolEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      hasUsageStatsPermission: hasUsageStatsPermission ?? this.hasUsageStatsPermission,
      hasAccessibilityPermission: hasAccessibilityPermission ?? this.hasAccessibilityPermission,
      hasOverlayPermission: hasOverlayPermission ?? this.hasOverlayPermission,
      hasNotificationPermission: hasNotificationPermission ?? this.hasNotificationPermission,
      timeReclaimedMinutes: timeReclaimedMinutes ?? this.timeReclaimedMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ============================================================================
// SETTINGS NOTIFIER
// ============================================================================
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    debugPrint('[SettingsNotifier::build] Initializing settings...');
    
    Future.microtask(() => _loadSettings());
    
    return const SettingsState(isLoading: true);
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Load settings from Hive
  // -------------------------------------------------------------------------
  Future<void> _loadSettings() async {
    debugPrint('[SettingsNotifier::_loadSettings] Loading from Hive...');

    try {
      if (!HiveService().isInitialized) {
        debugPrint('[SettingsNotifier::_loadSettings] Hive not initialized yet.');
        state = state.copyWith(isLoading: false);
        return;
      }

      final box = HiveService().settingsBox;

      // Load all settings from Hive
      final strictMode = box.get('strict_mode', defaultValue: false) as bool;
      final digestEnabled = box.get('digest_enabled', defaultValue: true) as bool;
      final hydraEnabled = box.get('hydra_enabled', defaultValue: true) as bool;
      final onboardingDone = box.get('onboarding_complete', defaultValue: false) as bool;

      // Load digest schedules
      final schedulesData = box.get('digest_schedules');
      List<DigestSchedule> schedules = const [
        DigestSchedule(hour: 13, minute: 0),
        DigestSchedule(hour: 18, minute: 0),
      ];
      if (schedulesData != null && schedulesData is List) {
        schedules = schedulesData
            .whereType<Map>()
            .map((m) => DigestSchedule.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }

      // Load stats
      final statsBox = HiveService().statsBox;
      final timeReclaimed = statsBox.get('time_reclaimed_minutes', defaultValue: 0) as int;
      final currentStreak = statsBox.get('current_streak', defaultValue: 0) as int;
      final longestStreak = statsBox.get('longest_streak', defaultValue: 0) as int;

      debugPrint('[SettingsNotifier::_loadSettings] Settings loaded successfully.');

      state = state.copyWith(
        strictModeEnabled: strictMode,
        digestEnabled: digestEnabled,
        digestSchedules: schedules,
        hydraProtocolEnabled: hydraEnabled,
        onboardingComplete: onboardingDone,
        timeReclaimedMinutes: timeReclaimed,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[SettingsNotifier::_loadSettings] ERROR: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Toggle strict mode
  // -------------------------------------------------------------------------
  Future<void> setStrictMode(bool enabled) async {
    debugPrint('[SettingsNotifier::setStrictMode] Setting to: $enabled');

    state = state.copyWith(strictModeEnabled: enabled);

    try {
      await HiveService().settingsBox.put('strict_mode', enabled);
    } catch (e) {
      debugPrint('[SettingsNotifier::setStrictMode] ERROR saving: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Toggle digest notifications
  // -------------------------------------------------------------------------
  Future<void> setDigestEnabled(bool enabled) async {
    debugPrint('[SettingsNotifier::setDigestEnabled] Setting to: $enabled');

    state = state.copyWith(digestEnabled: enabled);

    try {
      await HiveService().settingsBox.put('digest_enabled', enabled);
    } catch (e) {
      debugPrint('[SettingsNotifier::setDigestEnabled] ERROR saving: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Update digest schedules
  // -------------------------------------------------------------------------
  Future<void> updateDigestSchedules(List<DigestSchedule> schedules) async {
    debugPrint('[SettingsNotifier::updateDigestSchedules] Updating ${schedules.length} schedules');

    state = state.copyWith(digestSchedules: schedules);

    try {
      final maps = schedules.map((s) => s.toMap()).toList();
      await HiveService().settingsBox.put('digest_schedules', maps);
    } catch (e) {
      debugPrint('[SettingsNotifier::updateDigestSchedules] ERROR saving: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Toggle Hydra Protocol
  // -------------------------------------------------------------------------
  Future<void> setHydraProtocol(bool enabled) async {
    debugPrint('[SettingsNotifier::setHydraProtocol] Setting to: $enabled');

    state = state.copyWith(hydraProtocolEnabled: enabled);

    try {
      await HiveService().settingsBox.put('hydra_enabled', enabled);
    } catch (e) {
      debugPrint('[SettingsNotifier::setHydraProtocol] ERROR saving: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Complete onboarding
  // -------------------------------------------------------------------------
  Future<void> completeOnboarding() async {
    debugPrint('[SettingsNotifier::completeOnboarding] Marking complete.');

    state = state.copyWith(onboardingComplete: true);

    try {
      await HiveService().settingsBox.put('onboarding_complete', true);
    } catch (e) {
      debugPrint('[SettingsNotifier::completeOnboarding] ERROR saving: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Update permission status
  // -------------------------------------------------------------------------
  void updatePermissions({
    bool? usageStats,
    bool? accessibility,
    bool? overlay,
    bool? notification,
  }) {
    debugPrint('[SettingsNotifier::updatePermissions] Updating permission status.');

    state = state.copyWith(
      hasUsageStatsPermission: usageStats,
      hasAccessibilityPermission: accessibility,
      hasOverlayPermission: overlay,
      hasNotificationPermission: notification,
    );
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Add time reclaimed
  // -------------------------------------------------------------------------
  Future<void> addTimeReclaimed(int minutes) async {
    debugPrint('[SettingsNotifier::addTimeReclaimed] Adding $minutes minutes.');

    final newTotal = state.timeReclaimedMinutes + minutes;
    state = state.copyWith(timeReclaimedMinutes: newTotal);

    try {
      await HiveService().statsBox.put('time_reclaimed_minutes', newTotal);
    } catch (e) {
      debugPrint('[SettingsNotifier::addTimeReclaimed] ERROR saving: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Update streak
  // -------------------------------------------------------------------------
  Future<void> recordSuccessfulDay() async {
    debugPrint('[SettingsNotifier::recordSuccessfulDay] Recording success.');

    final newStreak = state.currentStreak + 1;
    final newLongest = newStreak > state.longestStreak ? newStreak : state.longestStreak;

    state = state.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
    );

    try {
      final statsBox = HiveService().statsBox;
      await statsBox.put('current_streak', newStreak);
      await statsBox.put('longest_streak', newLongest);
    } catch (e) {
      debugPrint('[SettingsNotifier::recordSuccessfulDay] ERROR saving: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC: Reset streak (on bypass)
  // -------------------------------------------------------------------------
  Future<void> resetStreak() async {
    debugPrint('[SettingsNotifier::resetStreak] Resetting streak to 0.');

    state = state.copyWith(currentStreak: 0);

    try {
      await HiveService().statsBox.put('current_streak', 0);
    } catch (e) {
      debugPrint('[SettingsNotifier::resetStreak] ERROR saving: $e');
    }
  }
}

// ============================================================================
// PROVIDER DEFINITION
// ============================================================================
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
