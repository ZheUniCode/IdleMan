// ============================================================================
// IDLEMAN v16.0 - DEFENSE PROVIDER
// ============================================================================
// File: lib/features/defense/providers/defense_provider.dart
// Purpose: Riverpod state management for the Mindful Defense System
// Philosophy: Levels of Awareness, not Levels of Punishment
// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/services/hive_service.dart';
import 'package:idleman/core/services/native_bridge.dart';

// ============================================================================
// DEFENSE LEVEL - The three stages of mindful intervention
// ============================================================================
enum DefenseLevel {
  // Level 1: Intent Check (0-15 minutes)
  // "What brought you here?"
  intentCheck,

  // Level 2: The Practice (15-45 minutes)
  // Must complete a mindful task (walking or math)
  practice,

  // Level 3: Hard Boundary (45+ minutes)
  // App is sealed; bypass requires commitment
  hardBoundary,
}

// ============================================================================
// PRACTICE TASK - Tasks required for Level 2
// ============================================================================
enum PracticeTask {
  // Walk 50 steps naturally
  mindfulWalk,

  // Solve 5 arithmetic problems
  focusActivation,
}

// ============================================================================
// DEFENSE STATE
// ============================================================================
class DefenseState {
  // -------------------------------------------------------------------------
  // Is defense system active?
  // -------------------------------------------------------------------------
  final bool isActive;

  // -------------------------------------------------------------------------
  // Current defense level
  // -------------------------------------------------------------------------
  final DefenseLevel currentLevel;

  // -------------------------------------------------------------------------
  // Target app information
  // -------------------------------------------------------------------------
  final String? targetPackage;
  final String? targetAppName;

  // -------------------------------------------------------------------------
  // Timer state (Level 1)
  // -------------------------------------------------------------------------
  final int selectedDurationMinutes;
  final int remainingSeconds;
  final bool isTimerRunning;

  // -------------------------------------------------------------------------
  // Practice state (Level 2)
  // -------------------------------------------------------------------------
  final PracticeTask? currentTask;
  final int stepsTaken;
  final int targetSteps;
  final int mathProblemsCompleted;
  final int mathProblemsTotal;
  final bool jerkDetected;

  // -------------------------------------------------------------------------
  // Session tracking
  // -------------------------------------------------------------------------
  final DateTime? sessionStartTime;
  final int totalUsageMinutesToday;

  const DefenseState({
    this.isActive = false,
    this.currentLevel = DefenseLevel.intentCheck,
    this.targetPackage,
    this.targetAppName,
    this.selectedDurationMinutes = 5,
    this.remainingSeconds = 0,
    this.isTimerRunning = false,
    this.currentTask,
    this.stepsTaken = 0,
    this.targetSteps = 50,
    this.mathProblemsCompleted = 0,
    this.mathProblemsTotal = 5,
    this.jerkDetected = false,
    this.sessionStartTime,
    this.totalUsageMinutesToday = 0,
  });

  // -------------------------------------------------------------------------
  // GETTERS
  // -------------------------------------------------------------------------
  String get remainingTimeFormatted {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get timerProgress {
    if (selectedDurationMinutes == 0) return 0;
    final totalSeconds = selectedDurationMinutes * 60;
    return 1 - (remainingSeconds / totalSeconds);
  }

  double get stepProgress {
    if (targetSteps == 0) return 0;
    return stepsTaken / targetSteps;
  }

  double get mathProgress {
    if (mathProblemsTotal == 0) return 0;
    return mathProblemsCompleted / mathProblemsTotal;
  }

  bool get isStepTaskComplete => stepsTaken >= targetSteps;
  bool get isMathTaskComplete => mathProblemsCompleted >= mathProblemsTotal;

  // -------------------------------------------------------------------------
  // COPY WITH
  // -------------------------------------------------------------------------
  DefenseState copyWith({
    bool? isActive,
    DefenseLevel? currentLevel,
    String? targetPackage,
    String? targetAppName,
    int? selectedDurationMinutes,
    int? remainingSeconds,
    bool? isTimerRunning,
    PracticeTask? currentTask,
    int? stepsTaken,
    int? targetSteps,
    int? mathProblemsCompleted,
    int? mathProblemsTotal,
    bool? jerkDetected,
    DateTime? sessionStartTime,
    int? totalUsageMinutesToday,
  }) {
    return DefenseState(
      isActive: isActive ?? this.isActive,
      currentLevel: currentLevel ?? this.currentLevel,
      targetPackage: targetPackage ?? this.targetPackage,
      targetAppName: targetAppName ?? this.targetAppName,
      selectedDurationMinutes: selectedDurationMinutes ?? this.selectedDurationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      currentTask: currentTask ?? this.currentTask,
      stepsTaken: stepsTaken ?? this.stepsTaken,
      targetSteps: targetSteps ?? this.targetSteps,
      mathProblemsCompleted: mathProblemsCompleted ?? this.mathProblemsCompleted,
      mathProblemsTotal: mathProblemsTotal ?? this.mathProblemsTotal,
      jerkDetected: jerkDetected ?? this.jerkDetected,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      totalUsageMinutesToday: totalUsageMinutesToday ?? this.totalUsageMinutesToday,
    );
  }
}

// ============================================================================
// DEFENSE NOTIFIER
// ============================================================================
class DefenseNotifier extends Notifier<DefenseState> {
  Timer? _countdownTimer;

  @override
  DefenseState build() {
    debugPrint('[DefenseNotifier::build] Initializing defense system.');

    // Setup native bridge callbacks
    _setupNativeCallbacks();

    // Cleanup timer on dispose
    ref.onDispose(() {
      debugPrint('[DefenseNotifier] Disposing, canceling timers.');
      _countdownTimer?.cancel();
    });

    return const DefenseState();
  }

  // -------------------------------------------------------------------------
  // Setup callbacks from native layer
  // -------------------------------------------------------------------------
  void _setupNativeCallbacks() {
    debugPrint('[DefenseNotifier::_setupNativeCallbacks] Setting up callbacks.');

    final bridge = NativeBridge();

    // When a bounded app is opened
    bridge.setOnBoundedAppOpened((packageName, appName) {
      debugPrint('[DefenseNotifier] Bounded app opened: $appName');
      triggerDefense(packageName: packageName, appName: appName);
    });

    // When an app is closed
    bridge.setOnAppClosed((packageName) {
      debugPrint('[DefenseNotifier] App closed: $packageName');
      if (state.targetPackage == packageName) {
        // User left the app naturally
        _handleAppClosed();
      }
    });

    // When a valid step is detected
    bridge.setOnStepDetected((isValid, totalSteps) {
      debugPrint('[DefenseNotifier] Step detected - Valid: $isValid, Total: $totalSteps');
      if (isValid) {
        _recordStep(totalSteps);
      }
    });

    // When jerk/shake is detected
    bridge.setOnJerkDetected(() {
      debugPrint('[DefenseNotifier] Jerk detected! Cheating attempt.');
      _handleJerkDetected();
    });
  }

  // -------------------------------------------------------------------------
  // TRIGGER: Start defense for a bounded app
  // -------------------------------------------------------------------------
  void triggerDefense({
    required String packageName,
    required String appName,
  }) {
    debugPrint('[DefenseNotifier::triggerDefense] ============================');
    debugPrint('[DefenseNotifier::triggerDefense] Triggered for: $appName');
    debugPrint('[DefenseNotifier::triggerDefense] ============================');

    // Determine the appropriate level based on today's usage
    final todayUsage = _getTodayUsageMinutes(packageName);
    final level = _determineLevel(todayUsage);

    debugPrint('[DefenseNotifier::triggerDefense] Today usage: ${todayUsage}m -> Level: $level');

    state = state.copyWith(
      isActive: true,
      currentLevel: level,
      targetPackage: packageName,
      targetAppName: appName,
      totalUsageMinutesToday: todayUsage,
      sessionStartTime: DateTime.now(),
      selectedDurationMinutes: 5,
      remainingSeconds: 0,
      isTimerRunning: false,
      stepsTaken: 0,
      mathProblemsCompleted: 0,
      jerkDetected: false,
    );
  }

  // -------------------------------------------------------------------------
  // LEVEL 1: User selects duration and confirms intent
  // -------------------------------------------------------------------------
  void confirmIntent(int durationMinutes) {
    debugPrint('[DefenseNotifier::confirmIntent] User selected ${durationMinutes}m');

    state = state.copyWith(
      selectedDurationMinutes: durationMinutes,
      remainingSeconds: durationMinutes * 60,
      isTimerRunning: true,
    );

    // Start countdown timer
    _startCountdownTimer();

    // Show ghost timer overlay
    NativeBridge().showGhostTimer(
      durationMinutes: durationMinutes,
      appName: state.targetAppName ?? 'App',
    );

    // Grant temporary access
    _grantAccess();
  }

  // -------------------------------------------------------------------------
  // LEVEL 2: Start practice task
  // -------------------------------------------------------------------------
  void startPracticeTask(PracticeTask task) {
    debugPrint('[DefenseNotifier::startPracticeTask] Starting: $task');

    state = state.copyWith(
      currentLevel: DefenseLevel.practice,
      currentTask: task,
      stepsTaken: 0,
      mathProblemsCompleted: 0,
      jerkDetected: false,
    );

    if (task == PracticeTask.mindfulWalk) {
      // Start step detection with jerk filter
      NativeBridge().startStepDetection(targetSteps: state.targetSteps);
    }
  }

  // -------------------------------------------------------------------------
  // LEVEL 2: Record math problem completion
  // -------------------------------------------------------------------------
  void completeMathProblem() {
    debugPrint('[DefenseNotifier::completeMathProblem] Problem completed.');

    final newCount = state.mathProblemsCompleted + 1;
    state = state.copyWith(mathProblemsCompleted: newCount);

    if (newCount >= state.mathProblemsTotal) {
      debugPrint('[DefenseNotifier] Math task complete!');
      _handlePracticeComplete();
    }
  }

  // -------------------------------------------------------------------------
  // LEVEL 3: Attempt bypass (requires IAP in strict mode)
  // -------------------------------------------------------------------------
  Future<bool> attemptBypass() async {
    debugPrint('[DefenseNotifier::attemptBypass] User attempting bypass.');

    // In a full implementation, this would:
    // 1. Check if strict mode is enabled
    // 2. If strict mode: require IAP
    // 3. If not strict: show confirmation and allow

    // For now, simulate bypass allowed (non-strict mode)
    _deactivateDefense();
    return true;
  }

  // -------------------------------------------------------------------------
  // EMERGENCY BYPASS: For urgent situations
  // Used from HardBoundaryScreen when user confirms emergency bypass
  // -------------------------------------------------------------------------
  void emergencyBypass() {
    debugPrint('[DefenseNotifier::emergencyBypass] Emergency bypass activated!');
    debugPrint('[DefenseNotifier::emergencyBypass] User explicitly bypassed hard boundary.');

    // Log the bypass for analytics
    _logBypassEvent();

    // Deactivate defense and allow access
    _deactivateDefense();
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Log bypass event for analytics
  // -------------------------------------------------------------------------
  void _logBypassEvent() {
    debugPrint('[DefenseNotifier::_logBypassEvent] Logging bypass event.');

    try {
      if (!HiveService().isInitialized) return;

      final box = HiveService().statsBox;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final key = 'bypass_count_$today';

      final currentCount = box.get(key, defaultValue: 0) as int;
      box.put(key, currentCount + 1);

      debugPrint('[DefenseNotifier::_logBypassEvent] Total bypasses today: ${currentCount + 1}');
    } catch (e) {
      debugPrint('[DefenseNotifier::_logBypassEvent] ERROR: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Deactivate defense system
  // -------------------------------------------------------------------------
  void _deactivateDefense() {
    debugPrint('[DefenseNotifier::_deactivateDefense] Deactivating.');

    _countdownTimer?.cancel();
    NativeBridge().dismissGhostTimer();
    NativeBridge().stopStepDetection();

    state = const DefenseState();
  }

  // -------------------------------------------------------------------------
  // Cancel and go back
  // -------------------------------------------------------------------------
  void cancel() {
    debugPrint('[DefenseNotifier::cancel] User canceled.');
    _deactivateDefense();
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Timer countdown logic
  // -------------------------------------------------------------------------
  void _startCountdownTimer() {
    debugPrint('[DefenseNotifier::_startCountdownTimer] Starting timer.');

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        timer.cancel();
        _handleTimerExpired();
        return;
      }

      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    });
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Handle timer expiration
  // -------------------------------------------------------------------------
  void _handleTimerExpired() {
    debugPrint('[DefenseNotifier::_handleTimerExpired] Timer expired!');

    // Check if user wants to extend (-> Level 2)
    state = state.copyWith(
      isTimerRunning: false,
    );

    // In full implementation, show extension dialog
    // If they extend beyond 15m total, trigger Level 2
    // If beyond 45m total, trigger Level 3
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Handle app closed
  // -------------------------------------------------------------------------
  void _handleAppClosed() {
    debugPrint('[DefenseNotifier::_handleAppClosed] Target app closed.');

    if (state.sessionStartTime != null) {
      final elapsed = DateTime.now().difference(state.sessionStartTime!);
      final minutes = elapsed.inMinutes;

      debugPrint('[DefenseNotifier] Session lasted: ${minutes}m');

      // Record time reclaimed if they left early
      if (state.isTimerRunning && state.remainingSeconds > 60) {
        final reclaimedMinutes = state.remainingSeconds ~/ 60;
        debugPrint('[DefenseNotifier] Reclaimed: ${reclaimedMinutes}m');
        // TODO: Update stats
      }
    }

    _deactivateDefense();
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Record step from pedometer
  // -------------------------------------------------------------------------
  void _recordStep(int totalSteps) {
    debugPrint('[DefenseNotifier::_recordStep] Steps: $totalSteps');

    state = state.copyWith(stepsTaken: totalSteps);

    if (totalSteps >= state.targetSteps) {
      debugPrint('[DefenseNotifier] Walk task complete!');
      NativeBridge().stopStepDetection();
      _handlePracticeComplete();
    }
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Handle jerk detection (cheat attempt)
  // -------------------------------------------------------------------------
  void _handleJerkDetected() {
    debugPrint('[DefenseNotifier::_handleJerkDetected] Cheat detected!');

    state = state.copyWith(jerkDetected: true);

    // Reset step count as penalty
    state = state.copyWith(stepsTaken: 0);
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Handle practice task completion
  // -------------------------------------------------------------------------
  void _handlePracticeComplete() {
    debugPrint('[DefenseNotifier::_handlePracticeComplete] Practice complete!');

    // Grant extended access (15 more minutes)
    state = state.copyWith(
      currentLevel: DefenseLevel.intentCheck,
      selectedDurationMinutes: 15,
      remainingSeconds: 15 * 60,
      isTimerRunning: true,
      currentTask: null,
    );

    _startCountdownTimer();

    NativeBridge().showGhostTimer(
      durationMinutes: 15,
      appName: state.targetAppName ?? 'App',
    );

    _grantAccess();
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Grant access to the app
  // -------------------------------------------------------------------------
  void _grantAccess() {
    debugPrint('[DefenseNotifier::_grantAccess] Access granted.');
    // In full implementation, this would dismiss the overlay
    // and allow the user to use the app
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Determine defense level based on usage
  // -------------------------------------------------------------------------
  DefenseLevel _determineLevel(int usageMinutes) {
    if (usageMinutes >= 45) {
      return DefenseLevel.hardBoundary;
    } else if (usageMinutes >= 15) {
      return DefenseLevel.practice;
    } else {
      return DefenseLevel.intentCheck;
    }
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Get today's usage for a package
  // -------------------------------------------------------------------------
  int _getTodayUsageMinutes(String packageName) {
    debugPrint('[DefenseNotifier::_getTodayUsageMinutes] Getting usage for: $packageName');

    try {
      if (!HiveService().isInitialized) return 0;

      final box = HiveService().statsBox;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final key = 'usage_${packageName}_$today';

      return box.get(key, defaultValue: 0) as int;
    } catch (e) {
      debugPrint('[DefenseNotifier::_getTodayUsageMinutes] ERROR: $e');
      return 0;
    }
  }
}

// ============================================================================
// PROVIDER DEFINITION
// ============================================================================
final defenseProvider = NotifierProvider<DefenseNotifier, DefenseState>(() {
  return DefenseNotifier();
});
