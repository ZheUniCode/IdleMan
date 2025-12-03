import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';

/// Splash Screen with logo positioned at top-right with 20% cut-off
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    // Navigate after 3 seconds, but check onboarding_complete flag
    Future.delayed(const Duration(seconds: 3), () async {
      final prefs = await Hive.openBox('settings');
      final completed = prefs.get('onboarding_complete', defaultValue: false) as bool;
      if (mounted) {
        if (completed) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // Logo positioned at top-right with 20% cut-off
          Positioned(
            top: 40,
            right: -size.width * 0.15, // 20% cut-off from right
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.background,
                  boxShadow: theme.getPopOutShadows(
                    distance: 15.0,
                    blur: 30.0,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        'IM',
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: theme.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // App name and tagline
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: theme.mainText,
                      // fontFamily removed
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.splashTagline,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.mainText
                          .withOpacity(0.87), // fontFamily removed
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
