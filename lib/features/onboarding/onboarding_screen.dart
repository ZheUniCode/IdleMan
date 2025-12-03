import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
// Ensure AppStrings is imported if not in app_constants.dart
import '../../widgets/neumorphic/neu_button.dart';
import '../../widgets/neumorphic/neu_background.dart';
import '../../core/services/platform_services.dart';
import 'onboarding_page.dart';

/// Onboarding Flow with Zoom Out scroll transition

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  Future<void> _nextPage() async {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: AppConstants.animationMedium),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding complete
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: theme.background,
      body: NeuBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      AppStrings.onboardingSkip,
                      style: TextStyle(
                        color: theme.mainText.withOpacity(0.87),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              // PageView with zoom-out transition
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions && _pageController.page != null) {
                          value = _pageController.page! - index;
                        } else {
                          value = (index == _currentPage) ? 0.0 : 1.0;
                        }
                        // Combine zooming (scale up), sliding, and fading out
                        double scale = (1.0 + value.abs() * 0.35).clamp(1.0, 1.35); // subtle growth
                        double offsetX = value * MediaQuery.of(context).size.width * 0.3; // slide left/right
                        double opacity = (1.0 - value.abs() * 2.0).clamp(0.02, 1.0); // fade out quicker
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(scale, scale)
                            ..translate(offsetX, 0.0),
                          child: Opacity(
                            opacity: opacity,
                            child: child,
                          ),
                        );
                      },
                      child: _buildPage(index),
                    );
                  },
                ),
              ),
              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingLarge,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => _buildIndicator(index == _currentPage, theme),
                  ),
                ),
              ),
              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: NeuButton(
                  onTap: _nextPage,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      _currentPage == 2
                          ? AppStrings.onboardingGetStarted
                          : AppStrings.onboardingNext,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.mainText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const OnboardingPage(
          title: AppStrings.onboardingWelcomeTitle,
          body: AppStrings.onboardingWelcomeBody,
          icon: Icons.psychology,
        );
      case 1:
        return const OnboardingPage(
          title: AppStrings.onboardingPermissionTitle,
          body: AppStrings.onboardingPermissionBody,
          icon: Icons.lock_open,
        );
      case 2:
        return const OnboardingPage(
          title: AppStrings.onboardingBlocklistTitle,
          body: AppStrings.onboardingBlocklistBody,
          icon: Icons.apps,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIndicator(bool isActive, dynamic theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: AppConstants.animationFast),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? theme.accent : theme.mainText.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
