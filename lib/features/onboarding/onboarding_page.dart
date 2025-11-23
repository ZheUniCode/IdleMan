import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/neumorphic/neu_card.dart';

/// Individual onboarding page component
class OnboardingPage extends ConsumerWidget {
  final String title;
  final String body;
  final IconData icon;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon in neumorphic circle
          NeuCard(
            borderRadius: 100,
            padding: const EdgeInsets.all(AppConstants.paddingXLarge),
            child: Icon(
              icon,
              size: 80,
              color: theme.accent,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.mainText,
              // fontFamily removed
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          // Body text
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.mainText.withOpacity(0.7),
              // fontFamily removed
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
