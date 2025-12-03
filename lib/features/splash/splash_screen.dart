import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';

/// Splash Screen with logo positioned at top-right with 20% cut-off
class SplashScreen extends ConsumerStatefulWidget {
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
