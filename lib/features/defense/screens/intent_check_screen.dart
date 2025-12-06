// ============================================================================
// IDLEMAN v16.0 - INTENT CHECK SCREEN (Level 1)
// ============================================================================
// File: lib/features/defense/screens/intent_check_screen.dart
// Purpose: The first line of mindful intervention
// Philosophy: "What brought you here?" - Awareness without judgment
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/theme/therapy_theme.dart';
import 'package:idleman/features/defense/providers/defense_provider.dart';

// ============================================================================
// INTENT CHECK SCREEN
// ============================================================================
class IntentCheckScreen extends ConsumerStatefulWidget {
  final String appName;
  final String packageName;

  const IntentCheckScreen({
    super.key,
    required this.appName,
    required this.packageName,
  });

  @override
  ConsumerState<IntentCheckScreen> createState() => _IntentCheckScreenState();
}

class _IntentCheckScreenState extends ConsumerState<IntentCheckScreen>
    with SingleTickerProviderStateMixin {
  // -------------------------------------------------------------------------
  // ANIMATION CONTROLLER
  // -------------------------------------------------------------------------
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // -------------------------------------------------------------------------
  // SELECTED DURATION
  // -------------------------------------------------------------------------
  int _selectedMinutes = 5;

  @override
  void initState() {
    super.initState();
    debugPrint('[IntentCheckScreen::initState] Initializing for: ${widget.appName}');

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[IntentCheckScreen::build] Building intent check UI.');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          _buildBlurredBackground(),

          // Content modal
          _buildContentModal(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // BLURRED BACKGROUND
  // -------------------------------------------------------------------------
  Widget _buildBlurredBackground() {
    debugPrint('[IntentCheckScreen::_buildBlurredBackground] Building blur backdrop.');

    return GestureDetector(
      onTap: () {
        debugPrint('[IntentCheckScreen] Background tapped - dismissing.');
        HapticFeedback.lightImpact();
        _dismiss();
      },
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10 * _fadeAnimation.value,
              sigmaY: 10 * _fadeAnimation.value,
            ),
            child: Container(
              color: TherapyColors.ink.withOpacity(0.3 * _fadeAnimation.value),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CONTENT MODAL
  // -------------------------------------------------------------------------
  Widget _buildContentModal() {
    debugPrint('[IntentCheckScreen::_buildContentModal] Building modal content.');

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: TherapyColors.canvas,
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: TherapyColors.ink.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              _buildHandleBar(),
              const SizedBox(height: 24),

              // App icon and name
              _buildAppHeader(),
              const SizedBox(height: 32),

              // Question
              _buildQuestion(),
              const SizedBox(height: 28),

              // Duration selector
              _buildDurationSelector(),
              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // HANDLE BAR
  // -------------------------------------------------------------------------
  Widget _buildHandleBar() {
    debugPrint('[IntentCheckScreen::_buildHandleBar] Building handle.');

    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: TherapyColors.graphite.withOpacity(0.3),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // APP HEADER
  // -------------------------------------------------------------------------
  Widget _buildAppHeader() {
    debugPrint('[IntentCheckScreen::_buildAppHeader] Building header for: ${widget.appName}');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App icon placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: TherapyColors.boundary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.apps_rounded,
            color: TherapyColors.boundary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.appName,
              style: TherapyText.heading2(),
            ),
            Text(
              'Boundary Active',
              style: TherapyText.caption().copyWith(
                color: TherapyColors.boundary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // QUESTION
  // -------------------------------------------------------------------------
  Widget _buildQuestion() {
    debugPrint('[IntentCheckScreen::_buildQuestion] Building question prompt.');

    return Column(
      children: [
        Text(
          'What brought you here?',
          style: TherapyText.heading3().copyWith(
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Take a moment to set your intention.',
          style: TherapyText.body().copyWith(
            color: TherapyColors.graphite,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // DURATION SELECTOR
  // -------------------------------------------------------------------------
  Widget _buildDurationSelector() {
    debugPrint('[IntentCheckScreen::_buildDurationSelector] Building duration options.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I need',
          style: TherapyText.caption().copyWith(
            color: TherapyColors.graphite,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDurationChip(5),
            const SizedBox(width: 12),
            _buildDurationChip(10),
            const SizedBox(width: 12),
            _buildDurationChip(15),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationChip(int minutes) {
    final isSelected = _selectedMinutes == minutes;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          debugPrint('[IntentCheckScreen] Duration selected: ${minutes}m');
          HapticFeedback.selectionClick();
          setState(() => _selectedMinutes = minutes);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? TherapyColors.growth : TherapyColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? TherapyColors.growth
                  : TherapyColors.graphite.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: TherapyColors.growth.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                '$minutes',
                style: TherapyText.heading2().copyWith(
                  color: isSelected ? TherapyColors.surface : TherapyColors.ink,
                ),
              ),
              Text(
                'min',
                style: TherapyText.caption().copyWith(
                  color: isSelected
                      ? TherapyColors.surface.withOpacity(0.8)
                      : TherapyColors.graphite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // ACTION BUTTONS
  // -------------------------------------------------------------------------
  Widget _buildActionButtons() {
    debugPrint('[IntentCheckScreen::_buildActionButtons] Building action buttons.');

    return Column(
      children: [
        // Primary: Confirm Intent
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              debugPrint('[IntentCheckScreen] Confirm intent: ${_selectedMinutes}m');
              HapticFeedback.mediumImpact();
              _confirmIntent();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TherapyColors.growth,
              foregroundColor: TherapyColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
            ),
            child: Text(
              'Begin Mindfully',
              style: TherapyText.body().copyWith(
                color: TherapyColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary: Go Back
        TextButton(
          onPressed: () {
            debugPrint('[IntentCheckScreen] Go back tapped.');
            HapticFeedback.lightImpact();
            _dismiss();
          },
          child: Text(
            'Actually, never mind',
            style: TherapyText.body().copyWith(
              color: TherapyColors.graphite,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // ACTIONS
  // -------------------------------------------------------------------------
  void _confirmIntent() {
    debugPrint('[IntentCheckScreen::_confirmIntent] User confirmed ${_selectedMinutes}m intent.');

    // Notify defense provider
    ref.read(defenseProvider.notifier).confirmIntent(_selectedMinutes);

    // Dismiss modal
    Navigator.of(context).pop(true);
  }

  void _dismiss() {
    debugPrint('[IntentCheckScreen::_dismiss] Dismissing modal.');

    // Notify defense provider
    ref.read(defenseProvider.notifier).cancel();

    // Dismiss modal
    Navigator.of(context).pop(false);
  }
}
