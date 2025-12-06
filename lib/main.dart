// ============================================================================
// IDLEMAN v16.0 - MAIN ENTRY POINT
// ============================================================================
// File: lib/main.dart
// Purpose: Application entry point and initialization
// Philosophy: Compassionate Discipline - Clinical Guardian, not Prison Warden
// ============================================================================

// Import Flutter's material design library
import 'package:flutter/material.dart';

// Import Flutter's services for system UI configuration
import 'package:flutter/services.dart';

// Import Riverpod for state management
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import our custom Hive service for local database
import 'package:idleman/core/services/hive_service.dart';

// Import Background Service for Hydra Protocol
import 'package:idleman/core/services/background_service.dart';

// Import Firebase Core
import 'package:firebase_core/firebase_core.dart';

// Import our Therapy Paper theme system
import 'package:idleman/core/theme/therapy_theme.dart';

// Import the Reflection screen (main dashboard)
import 'package:idleman/features/reflection/screens/reflection_screen.dart';

// Import the Home screen (navigation hub)
import 'package:idleman/features/dashboard/screens/home_screen.dart';

// Import the Onboarding screen
import 'package:idleman/features/onboarding/screens/onboarding_screen.dart';

// Import Settings provider to check onboarding status
import 'package:idleman/features/settings/providers/settings_provider.dart';

// ============================================================================
// MAIN FUNCTION
// ============================================================================
// The entry point of the application
// Initializes all services before running the app
// ============================================================================
void main() async {
  // Log application startup
  debugPrint('[main] ========================================================');
  debugPrint('[main] IDLEMAN v16.0 - PAPER GARDEN');
  debugPrint('[main] Starting application...');
  debugPrint('[main] ========================================================');

  // -------------------------------------------------------------------------
  // STEP 1: Ensure Flutter bindings are initialized
  // Required before calling any Flutter APIs in main()
  // -------------------------------------------------------------------------
  debugPrint('[main] Step 1: Ensuring Flutter bindings are initialized...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[main] Step 1: Flutter bindings initialized successfully.');

  // -------------------------------------------------------------------------
  // STEP 2: Configure system UI overlay style
  // Sets status bar and navigation bar to match Therapy Paper aesthetic
  // -------------------------------------------------------------------------
  debugPrint('[main] Step 2: Configuring system UI overlay style...');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Status bar color matches Canvas (Warm Cream)
      statusBarColor: Colors.transparent,
      // Status bar icons are dark (for light background)
      statusBarIconBrightness: Brightness.dark,
      // Navigation bar color matches Canvas
      systemNavigationBarColor: TherapyColors.canvas,
      // Navigation bar icons are dark
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  debugPrint('[main] Step 2: System UI overlay style configured.');

  // -------------------------------------------------------------------------
  // STEP 3: Set preferred orientations
  // IdleMan is designed for portrait mode only
  // -------------------------------------------------------------------------
  debugPrint('[main] Step 3: Setting preferred orientations...');
  await SystemChrome.setPreferredOrientations([
    // Allow portrait up orientation
    DeviceOrientation.portraitUp,
    // Allow portrait down orientation (upside down)
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('[main] Step 3: Preferred orientations set to portrait only.');

  // -------------------------------------------------------------------------
  // STEP 4: Initialize Hive local database
  // Required before any database operations
  // -------------------------------------------------------------------------
  debugPrint('[main] Step 4: Initializing Hive local database...');
  await HiveService().initialize();
  debugPrint('[main] Step 4: Hive local database initialized successfully.');

  // -------------------------------------------------------------------------
  // STEP 5: Initialize Firebase
  // Required for Garden and Auth
  // -------------------------------------------------------------------------
  debugPrint('[main] Step 5: Initializing Firebase...');
  try {
    await Firebase.initializeApp();
    debugPrint('[main] Step 5: Firebase initialized successfully.');
  } catch (e) {
    debugPrint('[main] Step 5: Firebase initialization failed (Offline Mode): $e');
  }

  // -------------------------------------------------------------------------
  // STEP 6: Initialize Background Service (Hydra Protocol)
  // Ensures resilience via WorkManager
  // -------------------------------------------------------------------------
  debugPrint('[main] Step 6: Initializing Background Service...');
  await BackgroundService().initialize();
  debugPrint('[main] Step 6: Background Service initialized.');

  // -------------------------------------------------------------------------
  // STEP 7: Initialize Therapy Paper theme (debug logging)
  // Logs all theme components for verification
  // -------------------------------------------------------------------------
  debugPrint('[main] Step 7: Initializing Therapy Paper theme...');
  TherapyTheme.debugInitialize();
  debugPrint('[main] Step 7: Therapy Paper theme initialized.');

  // -------------------------------------------------------------------------
  // STEP 8: Run the application
  // Wraps the app in ProviderScope for Riverpod state management
  // -------------------------------------------------------------------------
  debugPrint('[main] Step 8: Running IdleMan application...');
  debugPrint('[main] ========================================================');
  debugPrint('[main] INITIALIZATION COMPLETE - LAUNCHING UI');
  debugPrint('[main] ========================================================');
  
  // Run the app wrapped in ProviderScope for Riverpod
  runApp(
    // ProviderScope is required for Riverpod state management
    const ProviderScope(
      // The root widget of the application
      child: IdleManApp(),
    ),
  );
}

// ============================================================================
// IDLEMAN APP WIDGET
// ============================================================================
// The root widget of the application
// Configures MaterialApp with Therapy Paper theme
// ============================================================================
class IdleManApp extends ConsumerWidget {
  // -------------------------------------------------------------------------
  // Constructor - const for performance optimization
  // -------------------------------------------------------------------------
  const IdleManApp({super.key});

  // -------------------------------------------------------------------------
  // BUILD METHOD - Constructs the widget tree
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Log entry into build method
    debugPrint('[IdleManApp::build] Building IdleMan application widget...');

    // Log that we're creating the MaterialApp
    debugPrint('[IdleManApp::build] Creating MaterialApp with Therapy Paper theme...');

    // Return the MaterialApp widget
    return MaterialApp(
      // -----------------------------------------------------------------------
      // App metadata
      // -----------------------------------------------------------------------
      
      // Application title shown in task switcher
      title: 'IdleMan',
      
      // Disable the debug banner in release builds
      debugShowCheckedModeBanner: false,

      // -----------------------------------------------------------------------
      // Theme configuration - Therapy Paper aesthetic
      // -----------------------------------------------------------------------
      
      // Apply the Therapy Paper theme
      theme: TherapyTheme.theme,

      // -----------------------------------------------------------------------
      // Routes configuration
      // -----------------------------------------------------------------------
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/reflection': (context) => const ReflectionScreen(),
      },

      // -----------------------------------------------------------------------
      // Home screen - Check if onboarding is complete
      // -----------------------------------------------------------------------
      
      // Use a builder to check onboarding status
      home: const _InitialRouteDecider(),
    );
  }
}

// ============================================================================
// INITIAL ROUTE DECIDER
// ============================================================================
// Checks onboarding status and routes appropriately
// ============================================================================
class _InitialRouteDecider extends ConsumerWidget {
  const _InitialRouteDecider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[_InitialRouteDecider::build] Checking onboarding status...');

    // Watch settings state
    final settingsState = ref.watch(settingsProvider);

    // If settings are still loading, show splash
    if (settingsState.isLoading) {
      debugPrint('[_InitialRouteDecider] Settings loading, showing splash...');
      return Scaffold(
        backgroundColor: TherapyColors.canvas,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌱', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'IdleMan',
                style: TherapyText.heading1(),
              ),
              const SizedBox(height: 8),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(TherapyColors.growth),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      );
    }

    // Route based on onboarding status
    if (settingsState.onboardingComplete) {
      debugPrint('[_InitialRouteDecider] Onboarding complete, showing home...');
      return const HomeScreen();
    } else {
      debugPrint('[_InitialRouteDecider] Onboarding not complete, showing onboarding...');
      return const OnboardingScreen();
    }
  }
}
