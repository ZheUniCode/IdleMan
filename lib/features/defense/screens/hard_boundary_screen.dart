// ============================================================================
// IDLEMAN v16.0 - HARD BOUNDARY SCREEN (Level 3)
// ============================================================================
// File: lib/features/defense/screens/hard_boundary_screen.dart
// Purpose: Full-screen block when Level 2 times out
// Philosophy: Clear boundary with option for emergency access
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/theme/therapy_theme.dart';
import 'package:idleman/features/defense/providers/defense_provider.dart';

// ============================================================================
// HARD BOUNDARY SCREEN
// ============================================================================
class HardBoundaryScreen extends ConsumerStatefulWidget {
  final String appName;
  final String? appIcon;

  const HardBoundaryScreen({
    super.key,
    required this.appName,
    this.appIcon,
  });

  @override
  ConsumerState<HardBoundaryScreen> createState() => _HardBoundaryScreenState();
}

class _HardBoundaryScreenState extends ConsumerState<HardBoundaryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeAnimation;

  Timer? _countdownTimer;
  int _cooldownSeconds = 300; // 5 minutes default

  @override
  void initState() {
    super.initState();
    debugPrint('[HardBoundaryScreen::initState] Initializing screen.');

    // Pulse animation for the boundary icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();

    // Start cooldown timer
    _startCooldown();
  }

  void _startCooldown() {
    debugPrint('[HardBoundaryScreen::_startCooldown] Starting 5-minute cooldown.');

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_cooldownSeconds > 0) {
            _cooldownSeconds--;
          } else {
            timer.cancel();
            // Allow retry after cooldown
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    debugPrint('[HardBoundaryScreen::dispose] Cleaning up.');
    _pulseController.dispose();
    _fadeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[HardBoundaryScreen::build] Building hard boundary UI.');

    return WillPopScope(
      // Prevent back navigation
      onWillPop: () async {
        debugPrint('[HardBoundaryScreen] Back press blocked.');
        HapticFeedback.heavyImpact();
        return false;
      },
      child: Scaffold(
        backgroundColor: TherapyColors.boundary.withOpacity(0.95),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Boundary icon
                  _buildBoundaryIcon(),
                  const SizedBox(height: 40),

                  // Message
                  _buildMessage(),
                  const SizedBox(height: 32),

                  // Cooldown timer
                  _buildCooldownTimer(),

                  const Spacer(),

                  // Reflection prompt
                  _buildReflectionPrompt(),
                  const SizedBox(height: 24),

                  // Emergency bypass option
                  _buildEmergencyBypass(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // BOUNDARY ICON
  // -------------------------------------------------------------------------
  Widget _buildBoundaryIcon() {
    debugPrint('[HardBoundaryScreen::_buildBoundaryIcon] Building icon.');

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: TherapyColors.surface.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: TherapyColors.surface.withOpacity(0.3),
            width: 3,
          ),
        ),
        child: Icon(
          Icons.do_not_disturb_alt_rounded,
          size: 80,
          color: TherapyColors.surface,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // MESSAGE
  // -------------------------------------------------------------------------
  Widget _buildMessage() {
    debugPrint('[HardBoundaryScreen::_buildMessage] Building message.');

    return Column(
      children: [
        Text(
          'Boundary Reached',
          style: TherapyText.heading1().copyWith(
            color: TherapyColors.surface,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'You chose to set a boundary around ${widget.appName}. '
          'The practice task wasn\'t completed, so access is paused.',
          style: TherapyText.body().copyWith(
            color: TherapyColors.surface.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // COOLDOWN TIMER
  // -------------------------------------------------------------------------
  Widget _buildCooldownTimer() {
    debugPrint('[HardBoundaryScreen::_buildCooldownTimer] Cooldown: $_cooldownSeconds');

    final minutes = _cooldownSeconds ~/ 60;
    final seconds = _cooldownSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: TherapyColors.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: TherapyColors.surface.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Available again in',
            style: TherapyText.caption().copyWith(
              color: TherapyColors.surface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeString,
            style: TherapyText.heading1().copyWith(
              color: TherapyColors.surface,
              fontSize: 36,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // REFLECTION PROMPT
  // -------------------------------------------------------------------------
  Widget _buildReflectionPrompt() {
    debugPrint('[HardBoundaryScreen::_buildReflectionPrompt] Building reflection.');

    final prompts = [
      'What were you looking for when you opened this app?',
      'Is there something else that could meet this need?',
      'How are you feeling right now?',
      'What would "enough" look like today?',
      'What made you set this boundary in the first place?',
    ];

    // Select prompt based on time
    final promptIndex = DateTime.now().minute % prompts.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TherapyColors.surface.withOpacity(0.1),
        borderRadius: TherapyShapes.cardBorderRadius(),
      ),
      child: Column(
        children: [
          Icon(
            Icons.self_improvement_rounded,
            color: TherapyColors.surface.withOpacity(0.6),
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            prompts[promptIndex],
            style: TherapyText.body().copyWith(
              color: TherapyColors.surface.withOpacity(0.9),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // EMERGENCY BYPASS
  // -------------------------------------------------------------------------
  Widget _buildEmergencyBypass() {
    debugPrint('[HardBoundaryScreen::_buildEmergencyBypass] Building bypass option.');

    return Column(
      children: [
        Text(
          'Need urgent access?',
          style: TherapyText.caption().copyWith(
            color: TherapyColors.surface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _showEmergencyDialog,
          child: Text(
            'Emergency Bypass',
            style: TherapyText.body().copyWith(
              color: TherapyColors.surface.withOpacity(0.7),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showEmergencyDialog() {
    debugPrint('[HardBoundaryScreen::_showEmergencyDialog] Showing dialog.');
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TherapyColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: TherapyShapes.cardBorderRadius(),
        ),
        title: Text(
          'Emergency Bypass',
          style: TherapyText.heading2(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This option is for genuine emergencies only. '
              'Using it will reset your streak and be logged.',
              style: TherapyText.body().copyWith(
                color: TherapyColors.graphite,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you need to bypass this boundary?',
              style: TherapyText.body().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[HardBoundaryScreen] Emergency bypass cancelled.');
              Navigator.of(context).pop();
            },
            child: Text(
              'No, respect the boundary',
              style: TherapyText.button().copyWith(
                color: TherapyColors.growth,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              debugPrint('[HardBoundaryScreen] Emergency bypass confirmed!');
              HapticFeedback.heavyImpact();
              // Log bypass event
              ref.read(defenseProvider.notifier).emergencyBypass();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Close boundary screen
            },
            child: Text(
              'Yes, bypass',
              style: TherapyText.button().copyWith(
                color: TherapyColors.boundary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
