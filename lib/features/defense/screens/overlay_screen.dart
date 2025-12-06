// ============================================================================
// IDLEMAN v16.0 - OVERLAY SCREEN (INTENT CHECK)
// ============================================================================
// File: lib/features/defense/screens/overlay_screen.dart
// Purpose: The "Intent Check" overlay - Level 1 of the Mindful Defense System
// Philosophy: "What is your intention?" - Gentle pause, not aggressive block
// ============================================================================

// Import Flutter's material design library
import 'package:flutter/material.dart';

// Import Flutter's UI library for BackdropFilter
import 'dart:ui';

// Import Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import our theme system
import 'package:idleman/core/theme/therapy_theme.dart';

// ============================================================================
// INTENT DURATION ENUM
// ============================================================================
// The three options for how long the user intends to use the app
// Philosophy: "Quick Check", "Mindful Break", "Deep Dive" - no judgment
// ============================================================================
enum IntentDuration {
  // 5 minute quick check
  quickCheck(5, 'Quick Check', 'Just checking something briefly'),
  
  // 10 minute mindful break
  mindfulBreak(10, 'Mindful Break', 'Taking a short, intentional break'),
  
  // 15 minute deep dive
  deepDive(15, 'Deep Dive', 'Spending focused time here');

  // Duration in minutes
  final int minutes;
  
  // Display name for the button
  final String displayName;
  
  // Description text
  final String description;

  // Constructor
  const IntentDuration(this.minutes, this.displayName, this.description);
}

// ============================================================================
// OVERLAY STATE
// ============================================================================
// State management for the overlay screen
// ============================================================================
class OverlayState {
  // The selected duration (null = not yet selected)
  final IntentDuration? selectedDuration;
  
  // Whether the timer is active
  final bool isTimerActive;
  
  // Remaining time in seconds
  final int remainingSeconds;
  
  // The package name of the bounded app
  final String? boundedPackage;

  // Constructor
  const OverlayState({
    this.selectedDuration,
    this.isTimerActive = false,
    this.remainingSeconds = 0,
    this.boundedPackage,
  });

  // Copy with method for immutable updates
  OverlayState copyWith({
    IntentDuration? selectedDuration,
    bool? isTimerActive,
    int? remainingSeconds,
    String? boundedPackage,
  }) {
    return OverlayState(
      selectedDuration: selectedDuration ?? this.selectedDuration,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      boundedPackage: boundedPackage ?? this.boundedPackage,
    );
  }
}

// ============================================================================
// OVERLAY SCREEN
// ============================================================================
// The main "Intent Check" overlay with Gaussian Blur background
// Shows when a bounded app is launched - creates an "awareness moment"
// ============================================================================
class OverlayScreen extends ConsumerStatefulWidget {
  // The package name of the bounded app (passed from native)
  final String? boundedPackage;

  // Constructor
  const OverlayScreen({
    super.key,
    this.boundedPackage,
  });

  @override
  ConsumerState<OverlayScreen> createState() => _OverlayScreenState();
}

// ============================================================================
// OVERLAY SCREEN STATE
// ============================================================================
class _OverlayScreenState extends ConsumerState<OverlayScreen>
    with TickerProviderStateMixin {
  // -------------------------------------------------------------------------
  // STATE VARIABLES
  // -------------------------------------------------------------------------
  
  // Currently selected duration (null = none selected)
  IntentDuration? _selectedDuration;
  
  // Whether timer is currently running
  bool _isTimerActive = false;
  
  // Remaining time in seconds
  int _remainingSeconds = 0;

  // Animation controller for the modal entrance
  late AnimationController _entranceController;
  
  // Animation for modal slide up
  late Animation<Offset> _slideAnimation;
  
  // Animation for modal fade in
  late Animation<double> _fadeAnimation;

  // -------------------------------------------------------------------------
  // LIFECYCLE: initState
  // -------------------------------------------------------------------------
  @override
  void initState() {
    // Call parent implementation
    super.initState();
    
    // Log entry into initState
    debugPrint('[OverlayScreen::initState] Initializing overlay screen.');
    debugPrint('[OverlayScreen::initState] Bounded package: ${widget.boundedPackage}');
    
    // Initialize the entrance animation controller
    _entranceController = AnimationController(
      // Animation duration (300ms for smooth but quick entrance)
      duration: const Duration(milliseconds: 300),
      // Use this widget as the ticker provider
      vsync: this,
    );
    
    // Create the slide animation (from bottom to center)
    _slideAnimation = Tween<Offset>(
      // Start from below the screen
      begin: const Offset(0, 0.3),
      // End at center
      end: Offset.zero,
    ).animate(
      // Use easeOutBack for a slight bounce effect
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Create the fade animation
    _fadeAnimation = Tween<double>(
      // Start fully transparent
      begin: 0.0,
      // End fully opaque
      end: 1.0,
    ).animate(
      // Use easeOut for smooth fade
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start the entrance animation
    _entranceController.forward();
    
    // Log animation setup complete
    debugPrint('[OverlayScreen::initState] Entrance animation started.');
  }

  // -------------------------------------------------------------------------
  // LIFECYCLE: dispose
  // -------------------------------------------------------------------------
  @override
  void dispose() {
    // Log entry into dispose
    debugPrint('[OverlayScreen::dispose] Disposing overlay screen.');
    
    // Dispose animation controller
    _entranceController.dispose();
    
    // Log disposal complete
    debugPrint('[OverlayScreen::dispose] Animation controller disposed.');
    
    // Call parent implementation
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // BUILD METHOD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Log entry into build
    debugPrint('[OverlayScreen::build] Building overlay UI.');
    
    // Return the scaffold
    return Scaffold(
      // Transparent background to show blur
      backgroundColor: Colors.transparent,
      // The body with blur and modal
      body: Stack(
        // Stack children
        children: [
          // Background with Gaussian Blur
          _buildBlurredBackground(),
          
          // The modal content
          _buildModalContent(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the blurred background
  // -------------------------------------------------------------------------
  Widget _buildBlurredBackground() {
    // Log entry into method
    debugPrint('[OverlayScreen::_buildBlurredBackground] Building blurred background.');
    
    // Return the backdrop filter
    return Positioned.fill(
      child: GestureDetector(
        // Tapping background triggers "I don't need to be here" action
        onTap: _handleExitTap,
        // The blur filter
        child: BackdropFilter(
          // Gaussian blur with sigma 10 (as per spec)
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          // Semi-transparent overlay on top of blur
          child: Container(
            // Canvas color at 80% opacity for warm paper feel
            color: TherapyColors.canvas.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the modal content
  // -------------------------------------------------------------------------
  Widget _buildModalContent() {
    // Log entry into method
    debugPrint('[OverlayScreen::_buildModalContent] Building modal content.');
    
    // Return the animated modal
    return AnimatedBuilder(
      // Use the entrance animation
      animation: _entranceController,
      // Build the modal with animations applied
      builder: (context, child) {
        return Positioned(
          // Position at bottom of screen
          left: 0,
          right: 0,
          bottom: 0,
          // The modal container with animations
          child: SlideTransition(
            // Apply slide animation
            position: _slideAnimation,
            // Fade transition wrapper
            child: FadeTransition(
              // Apply fade animation
              opacity: _fadeAnimation,
              // The actual modal content
              child: _buildModalCard(),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the modal card
  // -------------------------------------------------------------------------
  Widget _buildModalCard() {
    // Log entry into method
    debugPrint('[OverlayScreen::_buildModalCard] Building modal card.');
    
    // Return the card container
    return Container(
      // Decoration for the card
      decoration: BoxDecoration(
        // Surface color (Pure White)
        color: TherapyColors.surface,
        // Rounded top corners only
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        // Elevated shadow
        boxShadow: TherapyShadows.elevated(),
      ),
      // Card padding
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      // Card content
      child: SafeArea(
        // Only apply bottom safe area
        top: false,
        // Column for vertical layout
        child: Column(
          // Minimum size
          mainAxisSize: MainAxisSize.min,
          // Children
          children: [
            // Handle bar (drag indicator)
            _buildHandleBar(),
            
            // Spacing
            const SizedBox(height: 24),
            
            // The therapeutic question
            _buildQuestion(),
            
            // Spacing
            const SizedBox(height: 32),
            
            // Duration selection buttons
            _buildDurationButtons(),
            
            // Spacing
            const SizedBox(height: 24),
            
            // Exit link
            _buildExitLink(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the handle bar (drag indicator)
  // -------------------------------------------------------------------------
  Widget _buildHandleBar() {
    // Log entry into method
    debugPrint('[OverlayScreen::_buildHandleBar] Building handle bar.');
    
    // Return the handle container
    return Container(
      // Handle dimensions
      width: 40,
      height: 4,
      // Handle decoration
      decoration: BoxDecoration(
        // Graphite color at low opacity
        color: TherapyColors.graphite.withOpacity(0.3),
        // Fully rounded
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the therapeutic question
  // -------------------------------------------------------------------------
  Widget _buildQuestion() {
    // Log entry into method
    debugPrint('[OverlayScreen::_buildQuestion] Building question section.');
    
    // Return column with question text
    return Column(
      // Children
      children: [
        // Main question (Serif font for authority)
        Text(
          'What is your intention?',
          style: TherapyText.heading1(),
          textAlign: TextAlign.center,
        ),
        
        // Spacing
        const SizedBox(height: 8),
        
        // Sub-text
        Text(
          'Take a moment to consider why you\'re here.',
          style: TherapyText.body().copyWith(
            color: TherapyColors.graphite,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build duration selection buttons
  // -------------------------------------------------------------------------
  Widget _buildDurationButtons() {
    // Log entry into method
    debugPrint('[OverlayScreen::_buildDurationButtons] Building duration buttons.');
    
    // Return column of buttons
    return Column(
      // Children - one button per duration option
      children: IntentDuration.values.map((duration) {
        // Build button for this duration
        return Padding(
          // Vertical padding between buttons
          padding: const EdgeInsets.only(bottom: 12),
          // The button
          child: _buildDurationButton(duration),
        );
      }).toList(),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build a single duration button
  // -------------------------------------------------------------------------
  Widget _buildDurationButton(IntentDuration duration) {
    // Log entry into method
    debugPrint('[OverlayScreen::_buildDurationButton] Building button for: ${duration.displayName}');
    
    // Check if this duration is selected
    final isSelected = _selectedDuration == duration;
    
    // Return the button
    return SizedBox(
      // Full width
      width: double.infinity,
      // The button
      child: OutlinedButton(
        // On press handler
        onPressed: () => _handleDurationSelected(duration),
        // Button style
        style: OutlinedButton.styleFrom(
          // Background color based on selection
          backgroundColor: isSelected 
              ? TherapyColors.growth.withOpacity(0.1) 
              : TherapyColors.surface,
          // Border color based on selection
          side: BorderSide(
            color: isSelected ? TherapyColors.growth : TherapyColors.graphite.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          // Pill shape
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TherapyShapes.buttonRadius),
          ),
          // Padding
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        // Button content
        child: Row(
          // Center content
          mainAxisAlignment: MainAxisAlignment.center,
          // Children
          children: [
            // Duration text
            Text(
              '${duration.displayName} (${duration.minutes}m)',
              style: TherapyText.button().copyWith(
                color: isSelected ? TherapyColors.growth : TherapyColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Build the exit link
  // -------------------------------------------------------------------------
  Widget _buildExitLink() {
    // Log entry into method
    debugPrint('[OverlayScreen::_buildExitLink] Building exit link.');
    
    // Return the text button
    return TextButton(
      // On press handler
      onPressed: _handleExitTap,
      // Button content
      child: Text(
        'I don\'t need to be here right now.',
        style: TherapyText.caption().copyWith(
          color: TherapyColors.graphite,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // HANDLER: Duration selected
  // -------------------------------------------------------------------------
  void _handleDurationSelected(IntentDuration duration) {
    // Log entry into handler
    debugPrint('[OverlayScreen::_handleDurationSelected] Duration selected: ${duration.displayName}');
    debugPrint('[OverlayScreen::_handleDurationSelected] Minutes: ${duration.minutes}');
    
    // Update state with selected duration
    setState(() {
      _selectedDuration = duration;
    });
    
    // Log state update
    debugPrint('[OverlayScreen::_handleDurationSelected] State updated.');
    
    // Grant temporary access and close overlay
    _grantAccessAndClose(duration);
  }

  // -------------------------------------------------------------------------
  // HANDLER: Exit tap (go home)
  // -------------------------------------------------------------------------
  void _handleExitTap() {
    // Log entry into handler
    debugPrint('[OverlayScreen::_handleExitTap] User chose to exit.');
    debugPrint('[OverlayScreen::_handleExitTap] Closing overlay and going home.');
    
    // Close the overlay (in a real implementation, this would trigger home intent)
    Navigator.of(context).pop();
    
    // Log action complete
    debugPrint('[OverlayScreen::_handleExitTap] Overlay closed.');
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Grant access and close overlay
  // -------------------------------------------------------------------------
  void _grantAccessAndClose(IntentDuration duration) {
    // Log entry into method
    debugPrint('[OverlayScreen::_grantAccessAndClose] ========================================');
    debugPrint('[OverlayScreen::_grantAccessAndClose] Granting temporary access.');
    debugPrint('[OverlayScreen::_grantAccessAndClose] Duration: ${duration.minutes} minutes');
    debugPrint('[OverlayScreen::_grantAccessAndClose] Package: ${widget.boundedPackage}');
    
    // TODO: Call native method to grant temporary access
    // This would communicate with AppMonitorService via MethodChannel
    
    // Close the overlay
    Navigator.of(context).pop();
    
    // Log completion
    debugPrint('[OverlayScreen::_grantAccessAndClose] Access granted. Overlay closed.');
    debugPrint('[OverlayScreen::_grantAccessAndClose] ========================================');
  }
}
