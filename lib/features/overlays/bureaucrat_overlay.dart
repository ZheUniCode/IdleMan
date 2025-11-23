import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_input.dart';
import '../../widgets/neumorphic/neu_button.dart';

/// The Neumorphic Bureaucrat Overlay
class BureaucratOverlay extends ConsumerStatefulWidget {
  const BureaucratOverlay({super.key});

  @override
  ConsumerState<BureaucratOverlay> createState() => _BureaucratOverlayState();
}

class _BureaucratOverlayState extends ConsumerState<BureaucratOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _durationController.dispose();
    _codeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Simple validation
    if (_reasonController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty ||
        _codeController.text.trim().isEmpty) {
      // Shake animation on failure
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Additional validation for code (must be "IDLE")
    if (_codeController.text.trim().toUpperCase() != 'IDLE') {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid verification code'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Success - close overlay
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppConstants.overlayBlurAmount,
              sigmaY: AppConstants.overlayBlurAmount,
            ),
            child: Container(
              color: theme.background
                  .withOpacity(AppConstants.overlayBackgroundOpacity),
            ),
          ),
          // Central floating card
          Center(
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: NeuCard(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: size.width * 0.9,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            AppStrings.bureaucratTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.mainText,
                              // fontFamily removed
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingLarge),
                          // Reason field
                          Text(
                            AppStrings.bureaucratReason,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.mainText.withOpacity(0.7),
                              // fontFamily removed
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          NeuInput(
                            controller: _reasonController,
                            hintText: AppStrings.bureaucratReasonHint,
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          // Duration field
                          Text(
                            AppStrings.bureaucratDuration,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.mainText.withOpacity(0.7),
                              // fontFamily removed
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          NeuInput(
                            controller: _durationController,
                            hintText: AppStrings.bureaucratDurationHint,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          // Code field
                          Text(
                            AppStrings.bureaucratCode,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.mainText.withOpacity(0.7),
                              // fontFamily removed
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          NeuInput(
                            controller: _codeController,
                            hintText: AppStrings.bureaucratCodeHint,
                          ),
                          const SizedBox(height: AppConstants.paddingLarge),
                          // Submit button
                          NeuButton(
                            onTap: _handleSubmit,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                AppStrings.bureaucratSubmit,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: theme.mainText,
                                  // fontFamily removed
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
