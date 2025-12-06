// ============================================================================
// IDLEMAN v16.0 - HYDRA PROTOCOL
// ============================================================================
// File: lib/core/services/hydra_protocol.dart
// Purpose: Keep IdleMan running reliably even when OS tries to kill it
// Philosophy: Compassionate persistence - always there when needed
// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/services/native_bridge.dart';

// ============================================================================
// HYDRA STATE
// ============================================================================
@immutable
class HydraState {
  final bool isEnabled;
  final bool isServiceAlive;
  final int restartCount;
  final DateTime? lastHealthCheck;
  final DateTime? lastRestart;
  final HydraStatus status;

  const HydraState({
    this.isEnabled = true,
    this.isServiceAlive = false,
    this.restartCount = 0,
    this.lastHealthCheck,
    this.lastRestart,
    this.status = HydraStatus.initializing,
  });

  HydraState copyWith({
    bool? isEnabled,
    bool? isServiceAlive,
    int? restartCount,
    DateTime? lastHealthCheck,
    DateTime? lastRestart,
    HydraStatus? status,
  }) {
    return HydraState(
      isEnabled: isEnabled ?? this.isEnabled,
      isServiceAlive: isServiceAlive ?? this.isServiceAlive,
      restartCount: restartCount ?? this.restartCount,
      lastHealthCheck: lastHealthCheck ?? this.lastHealthCheck,
      lastRestart: lastRestart ?? this.lastRestart,
      status: status ?? this.status,
    );
  }
}

enum HydraStatus {
  initializing,
  healthy,
  recovering,
  degraded,
  disabled,
}

// ============================================================================
// HYDRA NOTIFIER
// ============================================================================
class HydraNotifier extends StateNotifier<HydraState> {
  final NativeBridge _nativeBridge;
  Timer? _healthCheckTimer;
  Timer? _watchdogTimer;

  // Health check interval (every 30 seconds)
  static const _healthCheckInterval = Duration(seconds: 30);

  // Watchdog interval (every 5 minutes to trigger restart if needed)
  static const _watchdogInterval = Duration(minutes: 5);

  // Max restart attempts before giving up
  static const _maxRestartAttempts = 3;

  HydraNotifier(this._nativeBridge) : super(const HydraState()) {
    debugPrint('[HydraNotifier] Initializing Hydra Protocol.');
    _initialize();
  }

  // -------------------------------------------------------------------------
  // INITIALIZATION
  // -------------------------------------------------------------------------
  Future<void> _initialize() async {
    debugPrint('[HydraNotifier::_initialize] Starting initialization.');

    // Check initial service state
    await _performHealthCheck();

    // Start periodic health checks
    _startHealthMonitoring();

    debugPrint('[HydraNotifier] Hydra Protocol initialized.');
  }

  // -------------------------------------------------------------------------
  // HEALTH MONITORING
  // -------------------------------------------------------------------------
  void _startHealthMonitoring() {
    debugPrint('[HydraNotifier::_startHealthMonitoring] Starting monitors.');

    // Cancel existing timers
    _healthCheckTimer?.cancel();
    _watchdogTimer?.cancel();

    // Regular health checks
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) {
      _performHealthCheck();
    });

    // Watchdog for recovery
    _watchdogTimer = Timer.periodic(_watchdogInterval, (_) {
      _watchdogCheck();
    });
  }

  Future<void> _performHealthCheck() async {
    debugPrint('[HydraNotifier::_performHealthCheck] Checking health.');

    if (!state.isEnabled) {
      state = state.copyWith(
        status: HydraStatus.disabled,
        lastHealthCheck: DateTime.now(),
      );
      return;
    }

    try {
      // Check if accessibility service is running
      final isAccessibilityAlive = await _nativeBridge.isAccessibilityServiceEnabled();

      // Check if overlay permission is granted
      final hasOverlay = await _nativeBridge.hasOverlayPermission();

      // Service is "alive" if both are working
      final isAlive = isAccessibilityAlive && hasOverlay;

      final newStatus = isAlive ? HydraStatus.healthy : HydraStatus.degraded;

      state = state.copyWith(
        isServiceAlive: isAlive,
        lastHealthCheck: DateTime.now(),
        status: newStatus,
      );

      debugPrint('[HydraNotifier] Health: $newStatus (accessibility=$isAccessibilityAlive, overlay=$hasOverlay)');

    } catch (e) {
      debugPrint('[HydraNotifier::_performHealthCheck] Error: $e');
      state = state.copyWith(
        isServiceAlive: false,
        status: HydraStatus.degraded,
        lastHealthCheck: DateTime.now(),
      );
    }
  }

  Future<void> _watchdogCheck() async {
    debugPrint('[HydraNotifier::_watchdogCheck] Watchdog triggered.');

    if (!state.isEnabled) return;

    // If service is dead, attempt recovery
    if (!state.isServiceAlive && state.status != HydraStatus.recovering) {
      await _attemptRecovery();
    }
  }

  // -------------------------------------------------------------------------
  // RECOVERY
  // -------------------------------------------------------------------------
  Future<void> _attemptRecovery() async {
    debugPrint('[HydraNotifier::_attemptRecovery] Attempting recovery.');

    if (state.restartCount >= _maxRestartAttempts) {
      debugPrint('[HydraNotifier] Max restart attempts reached.');
      state = state.copyWith(status: HydraStatus.degraded);
      return;
    }

    state = state.copyWith(status: HydraStatus.recovering);

    try {
      // Request accessibility service restart
      final accessibilityEnabled = await _nativeBridge.isAccessibilityServiceEnabled();

      if (!accessibilityEnabled) {
        debugPrint('[HydraNotifier] Accessibility service needs re-enabling.');
        // Can't auto-restart accessibility service, user needs to enable it
        // We can show a notification though
        await _nativeBridge.showServiceDownNotification();
      }

      state = state.copyWith(
        restartCount: state.restartCount + 1,
        lastRestart: DateTime.now(),
      );

      // Recheck health after recovery attempt
      await Future.delayed(const Duration(seconds: 2));
      await _performHealthCheck();

    } catch (e) {
      debugPrint('[HydraNotifier::_attemptRecovery] Error: $e');
      state = state.copyWith(status: HydraStatus.degraded);
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC METHODS
  // -------------------------------------------------------------------------
  Future<void> setEnabled(bool enabled) async {
    debugPrint('[HydraNotifier::setEnabled] Setting to: $enabled');

    state = state.copyWith(
      isEnabled: enabled,
      status: enabled ? HydraStatus.initializing : HydraStatus.disabled,
    );

    if (enabled) {
      _startHealthMonitoring();
      await _performHealthCheck();
    } else {
      _healthCheckTimer?.cancel();
      _watchdogTimer?.cancel();
    }
  }

  Future<void> forceHealthCheck() async {
    debugPrint('[HydraNotifier::forceHealthCheck] Manual health check.');
    await _performHealthCheck();
  }

  void resetRestartCount() {
    debugPrint('[HydraNotifier::resetRestartCount] Resetting count.');
    state = state.copyWith(restartCount: 0);
  }

  // -------------------------------------------------------------------------
  // CLEANUP
  // -------------------------------------------------------------------------
  @override
  void dispose() {
    debugPrint('[HydraNotifier::dispose] Cleaning up.');
    _healthCheckTimer?.cancel();
    _watchdogTimer?.cancel();
    super.dispose();
  }
}

// ============================================================================
// PROVIDER
// ============================================================================
final hydraProvider = StateNotifierProvider<HydraNotifier, HydraState>((ref) {
  final nativeBridge = ref.watch(nativeBridgeProvider);
  return HydraNotifier(nativeBridge);
});

// Convenience providers
final hydraStatusProvider = Provider<HydraStatus>((ref) {
  return ref.watch(hydraProvider).status;
});

final isServiceHealthyProvider = Provider<bool>((ref) {
  final state = ref.watch(hydraProvider);
  return state.isServiceAlive && state.status == HydraStatus.healthy;
});
