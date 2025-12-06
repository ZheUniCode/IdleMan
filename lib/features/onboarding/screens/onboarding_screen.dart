// ============================================================================
// IDLEMAN v16.0 - ONBOARDING SCREEN
// ============================================================================
// File: lib/features/onboarding/screens/onboarding_screen.dart
// Purpose: Guide new users through setup with compassionate framing
// Philosophy: "Your boundaries, your pace" - no guilt, just support
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/theme/therapy_theme.dart';
import 'package:idleman/core/services/native_bridge.dart';
import 'package:idleman/features/settings/providers/settings_provider.dart';

// ============================================================================
// ONBOARDING SCREEN
// ============================================================================
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Permission states
  bool _hasUsageStats = false;
  bool _hasAccessibility = false;
  bool _hasNotifications = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[OnboardingScreen::initState] Initializing.');
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    debugPrint('[OnboardingScreen::_checkPermissions] Checking permissions.');
    final bridge = ref.read(nativeBridgeProvider);

    final usage = await bridge.hasUsageStatsPermission();
    final accessibility = await bridge.isAccessibilityServiceEnabled();
    final notifications = await bridge.hasNotificationListenerAccess();

    if (mounted) {
      setState(() {
        _hasUsageStats = usage;
        _hasAccessibility = accessibility;
        _hasNotifications = notifications;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[OnboardingScreen::build] Building page $_currentPage.');

    return Scaffold(
      backgroundColor: TherapyColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _checkPermissions();
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(),
                  _buildPhilosophyPage(),
                  _buildUsageStatsPage(),
                  _buildAccessibilityPage(),
                  _buildNotificationsPage(),
                  _buildReadyPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PROGRESS INDICATOR
  // -------------------------------------------------------------------------
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(6, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 5 ? 4 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? TherapyColors.growth
                    : TherapyColors.graphite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          );
        }),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PAGE 1: WELCOME
  // -------------------------------------------------------------------------
  Widget _buildWelcomePage() {
    debugPrint('[OnboardingScreen::_buildWelcomePage] Building welcome.');

    return _OnboardingPage(
      illustration: '🌱',
      title: 'Welcome to IdleMan',
      subtitle: 'Your companion for mindful digital habits',
      body: 'IdleMan helps you set boundaries around apps that tend to '
          'steal your focus. No judgment, no guilt—just gentle support '
          'to help you use your time intentionally.',
      buttonText: 'Let\'s Begin',
      onNext: _nextPage,
    );
  }

  // -------------------------------------------------------------------------
  // PAGE 2: PHILOSOPHY
  // -------------------------------------------------------------------------
  Widget _buildPhilosophyPage() {
    debugPrint('[OnboardingScreen::_buildPhilosophyPage] Building philosophy.');

    return _OnboardingPage(
      illustration: '💚',
      title: 'Compassionate Discipline',
      subtitle: 'Not about restriction—about choice',
      body: 'Traditional screen time apps use shame and guilt. '
          'We believe boundaries should feel supportive, not punishing.\n\n'
          'You\'re in control. You set the pace. We\'re just here to help.',
      buttonText: 'I Like That',
      onNext: _nextPage,
    );
  }

  // -------------------------------------------------------------------------
  // PAGE 3: USAGE STATS PERMISSION
  // -------------------------------------------------------------------------
  Widget _buildUsageStatsPage() {
    debugPrint('[OnboardingScreen::_buildUsageStatsPage] Building usage stats.');

    return _OnboardingPage(
      illustration: '📊',
      title: 'See Your Patterns',
      subtitle: 'Usage stats help you reflect',
      body: 'To show you which apps take up your time, we need permission '
          'to view your usage statistics.\n\n'
          'This data stays on your device. We never upload it anywhere.',
      buttonText: _hasUsageStats ? 'Permission Granted ✓' : 'Grant Permission',
      buttonColor: _hasUsageStats ? TherapyColors.growth : null,
      onNext: () async {
        if (!_hasUsageStats) {
          HapticFeedback.mediumImpact();
          final bridge = ref.read(nativeBridgeProvider);
          await bridge.requestUsageStatsPermission();
          // Check if permission was granted after user returns
          await Future.delayed(const Duration(milliseconds: 500));
          final granted = await bridge.hasUsageStatsPermission();
          if (granted && mounted) {
            setState(() => _hasUsageStats = true);
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }
        _nextPage();
      },
      showSkip: !_hasUsageStats,
      onSkip: _nextPage,
    );
  }

  // -------------------------------------------------------------------------
  // PAGE 4: ACCESSIBILITY SERVICE
  // -------------------------------------------------------------------------
  Widget _buildAccessibilityPage() {
    debugPrint('[OnboardingScreen::_buildAccessibilityPage] Building accessibility.');

    return _OnboardingPage(
      illustration: '🛡️',
      title: 'Enable Your Shield',
      subtitle: 'The heart of your defense system',
      body: 'To show you gentle reminders when opening bounded apps, '
          'IdleMan needs accessibility permissions.\n\n'
          'This lets us show you a pause before auto-pilot kicks in.',
      buttonText: _hasAccessibility ? 'Shield Active ✓' : 'Activate Shield',
      buttonColor: _hasAccessibility ? TherapyColors.growth : null,
      onNext: () async {
        if (!_hasAccessibility) {
          HapticFeedback.mediumImpact();
          final bridge = ref.read(nativeBridgeProvider);
          await bridge.openAccessibilitySettings();
          // Check if permission was granted after user returns
          await Future.delayed(const Duration(milliseconds: 500));
          final granted = await bridge.isAccessibilityServiceEnabled();
          if (granted && mounted) {
            setState(() => _hasAccessibility = true);
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }
        _nextPage();
      },
      showSkip: !_hasAccessibility,
      onSkip: _nextPage,
    );
  }

  // -------------------------------------------------------------------------
  // PAGE 5: NOTIFICATIONS (OPTIONAL)
  // -------------------------------------------------------------------------
  Widget _buildNotificationsPage() {
    debugPrint('[OnboardingScreen::_buildNotificationsPage] Building notifications.');

    return _OnboardingPage(
      illustration: '🔔',
      title: 'Calm Notifications',
      subtitle: 'Optional: Batch your interruptions',
      body: 'Want to reduce constant pings? Enable notification digest '
          'to receive updates in calm, scheduled batches.\n\n'
          'This is completely optional—skip if you prefer real-time notifications.',
      buttonText: _hasNotifications ? 'Digest Enabled ✓' : 'Enable Digest',
      buttonColor: _hasNotifications ? TherapyColors.growth : null,
      onNext: () async {
        if (!_hasNotifications) {
          HapticFeedback.mediumImpact();
          final bridge = ref.read(nativeBridgeProvider);
          await bridge.requestNotificationListenerAccess();
          // Check if permission was granted after user returns
          await Future.delayed(const Duration(milliseconds: 500));
          final granted = await bridge.hasNotificationListenerAccess();
          if (granted && mounted) {
            setState(() => _hasNotifications = true);
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }
        _nextPage();
      },
      showSkip: true,
      onSkip: _nextPage,
      skipText: 'Maybe Later',
    );
  }

  // -------------------------------------------------------------------------
  // PAGE 6: READY
  // -------------------------------------------------------------------------
  Widget _buildReadyPage() {
    debugPrint('[OnboardingScreen::_buildReadyPage] Building ready page.');

    final permissionCount = [_hasUsageStats, _hasAccessibility, _hasNotifications]
        .where((p) => p)
        .length;

    return _OnboardingPage(
      illustration: '🌸',
      title: 'You\'re Ready',
      subtitle: '$permissionCount of 3 permissions enabled',
      body: 'You can always adjust permissions later in Settings.\n\n'
          'Now let\'s choose which apps you\'d like to set boundaries around. '
          'Start small—even one app can make a difference.',
      buttonText: 'Start Growing',
      buttonColor: TherapyColors.growth,
      onNext: _completeOnboarding,
    );
  }

  // -------------------------------------------------------------------------
  // NAVIGATION
  // -------------------------------------------------------------------------
  void _nextPage() {
    debugPrint('[OnboardingScreen::_nextPage] Going to next page.');
    HapticFeedback.lightImpact();
    
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    debugPrint('[OnboardingScreen::_completeOnboarding] Completing onboarding.');
    HapticFeedback.mediumImpact();

    // Mark onboarding complete
    ref.read(settingsProvider.notifier).completeOnboarding();

    // Navigate to main app
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

// ============================================================================
// ONBOARDING PAGE TEMPLATE
// ============================================================================
class _OnboardingPage extends StatelessWidget {
  final String illustration;
  final String title;
  final String subtitle;
  final String body;
  final String buttonText;
  final Color? buttonColor;
  final VoidCallback onNext;
  final bool showSkip;
  final VoidCallback? onSkip;
  final String skipText;

  const _OnboardingPage({
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.buttonText,
    this.buttonColor,
    required this.onNext,
    this.showSkip = false,
    this.onSkip,
    this.skipText = 'Skip',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: TherapyColors.growth.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                illustration,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: TherapyText.heading1(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: TherapyText.body().copyWith(
              color: TherapyColors.growth,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Body
          Text(
            body,
            style: TherapyText.body().copyWith(
              color: TherapyColors.graphite,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 2),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? TherapyColors.ink,
                foregroundColor: TherapyColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: TherapyText.button().copyWith(
                  color: TherapyColors.surface,
                ),
              ),
            ),
          ),

          // Skip button
          if (showSkip) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onSkip,
              child: Text(
                skipText,
                style: TherapyText.body().copyWith(
                  color: TherapyColors.graphite,
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
