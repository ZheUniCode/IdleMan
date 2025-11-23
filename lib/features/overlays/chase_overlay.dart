import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/neumorphic/neu_card.dart';
import '../../widgets/neumorphic/neu_button.dart';

/// The Kinetic Chase Overlay
class ChaseOverlay extends ConsumerStatefulWidget {
  const ChaseOverlay({super.key});

  @override
  ConsumerState<ChaseOverlay> createState() => _ChaseOverlayState();
}

class _ChaseOverlayState extends ConsumerState<ChaseOverlay> {
  int _tapCount = 0;
  Offset _buttonPosition = const Offset(150, 300);
  final math.Random _random = math.Random();

  void _handleTap() {
    HapticFeedback.lightImpact();
    
    setState(() {
      _tapCount++;
      
      if (_tapCount >= AppConstants.chaseTargetCount) {
        // Success - close overlay
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop();
        return;
      }

      // Teleport button to new random position
      _teleportButton();
    });
  }

  void _teleportButton() {
    final size = MediaQuery.of(context).size;
    
    // Calculate safe area within the card
    const cardPadding = AppConstants.paddingLarge * 2;
    final maxX = size.width - AppConstants.chaseButtonSize - cardPadding * 2;
    final maxY = size.height * 0.5 - AppConstants.chaseButtonSize;

    setState(() {
      _buttonPosition = Offset(
        _random.nextDouble() * maxX + cardPadding,
        _random.nextDouble() * maxY,
      );
    });
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
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: NeuCard(
                child: Container(
                  width: size.width * 0.9,
                  height: size.height * 0.7,
                  child: Column(
                    children: [
                      // Header with counter
                      Text(
                        AppStrings.chaseTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: theme.mainText,
                          // fontFamily removed
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        '$_tapCount / ${AppConstants.chaseTargetCount}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.accent,
                          // fontFamily removed
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      // Chase area
                      Expanded(
                        child: Stack(
                          children: [
                            // Teleporting button
                            AnimatedPositioned(
                              duration: Duration.zero, // Instant teleport
                              left: _buttonPosition.dx,
                              top: _buttonPosition.dy,
                              child: _buildChaseButton(theme),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaseButton(theme) {
    return NeuButton(
      onTap: _handleTap,
      padding: EdgeInsets.zero,
      borderRadius: AppConstants.chaseButtonSize / 2,
      child: Container(
        width: AppConstants.chaseButtonSize,
        height: AppConstants.chaseButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              theme.accent.withOpacity(0.8),
              theme.accent,
            ],
          ),
        ),
        child: const Icon(
          Icons.touch_app,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
