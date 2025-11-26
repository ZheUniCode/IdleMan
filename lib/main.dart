import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/theme_provider.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/overlays/typing_overlay.dart';
import 'features/overlays/chase_overlay.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

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

  // Initialize Hive for overlay
  await Hive.initFlutter();

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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class OverlayApp extends ConsumerWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    // Randomly choose between typing and chase overlay
    final random = math.Random();
    final showTyping = random.nextBool();

    return MaterialApp(
      title: 'IdleMan Overlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: theme.accent,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.accent,
          brightness: theme.isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      home: showTyping ? TypingOverlay() : ChaseOverlay(),
    );
  }
}
