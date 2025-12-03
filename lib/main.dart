import 'overlay_main.dart' show OverlayApp;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed Hive import
import 'core/theme/theme_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/overlays/chase_overlay.dart';
import 'dart:math' as math;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Removed Hive initialization

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: IdleManApp(),
    ),
  );
}

// Separate entry point for overlay activity
@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Removed Hive initialization for overlay

  runApp(
    const ProviderScope(
      child: OverlayApp(),
    ),
  );
}

class IdleManApp extends ConsumerWidget {
  const IdleManApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'IdleMan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: theme.accent,
        scaffoldBackgroundColor: theme.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.accent,
          brightness: theme.isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

