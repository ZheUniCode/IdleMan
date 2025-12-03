/// Design system constants for IdleMan app

class AppConstants {
  // Border Radius
  static const double borderRadiusCard = 30.0;
  static const double borderRadiusButton = 20.0;
  static const double borderRadiusInput = 12.0;
  static const double borderRadiusSmall = 8.0;

  // Shadow distances
  static const double shadowDistanceLarge = 10.0;
  static const double shadowDistanceMedium = 6.0;
  static const double shadowDistanceSmall = 4.0;

  // Shadow blur
  static const double shadowBlurLarge = 20.0;
  static const double shadowBlurMedium = 15.0;
  static const double shadowBlurSmall = 10.0;

  // Padding & Spacing
  static const double paddingXLarge = 32.0;
  static const double paddingLarge = 24.0;
  static const double paddingMedium = 16.0;
  static const double paddingSmall = 12.0;
  static const double paddingXSmall = 8.0;

  // Animation durations (milliseconds)
  static const int animationFast = 200;
  static const int animationMedium = 350;
  static const int animationSlow = 500;

  // Jelly animation constants
  static const double jellyScaleDown = 0.95;
  static const double jellyScaleUp = 1.05;

  // Overlay constants
  static const double overlayBlurAmount = 10.0;
  static const double overlayBackgroundOpacity = 0.3;

  // Chase game constants
  static const int chaseTargetCount = 10; // Reduced for testing
  static const double chaseButtonSize = 80.0;

  // Bypass duration (minutes)
  static const int defaultBypassDuration =
      15; // Default time granted after completing overlay
}

enum OverlayType {
  bureaucrat,
  chase,
  typing,
  random;

  String get displayName {
    switch (this) {
      case OverlayType.bureaucrat:
        return 'Bureaucrat';
      case OverlayType.chase:
        return 'Chase';
      case OverlayType.typing:
        return 'Typing';
      case OverlayType.random:
        return 'Random';
    }
  }

  String get routeName {
    switch (this) {
      case OverlayType.bureaucrat:
        return '/overlay/bureaucrat';
      case OverlayType.chase:
        return '/overlay/chase';
      case OverlayType.typing:
        return '/overlay/typing';
      case OverlayType.random:
        return '/overlay/random'; // Not a real route, used for logic
    }
  }
}

class AppStrings {
  // App
  static const String appName = 'IdleMan';

  // Splash
  static const String splashTagline = 'Break the idle habit';

  // Onboarding
  static const String onboardingWelcomeTitle = 'Welcome to IdleMan';
  static const String onboardingWelcomeBody =
      'Take control of your digital habits with tactile cognitive friction.';
  static const String onboardingPermissionTitle = 'Grant Permissions';
  static const String onboardingPermissionBody =
      'IdleMan needs Accessibility and Overlay permissions to work.';
  static const String onboardingBlocklistTitle = 'Choose Apps to Monitor';
  static const String onboardingBlocklistBody =
      'Select which apps you want IdleMan to interrupt.';
  static const String onboardingGetStarted = 'Get Started';
  static const String onboardingNext = 'Next';
  static const String onboardingSkip = 'Skip';

  // Dashboard
  static const String dashboardActiveStatus = 'IdleMan is Active';
  static const String dashboardInactiveStatus = 'IdleMan is Inactive';
  static const String dashboardInterruptionsToday = 'Interruptions Today';
  static const String dashboardAppsBlocked = 'Apps Blocked';
  static const String dashboardSettings = 'Settings';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String settingsThemeToggle = 'Theme';
  static const String settingsThemeDay = 'Day Mode';
  static const String settingsThemeNight = 'Night Mode';
  static const String settingsBlocklist = 'Blocked Apps';
  static const String settingsPermissions = 'Permissions';

  // Overlays
  static const String bureaucratTitle = 'Verification Required by IdleMan';
  static const String bureaucratReason = 'Reason';
  static const String bureaucratDuration = 'Duration';
  static const String bureaucratCode = 'Priority Level';
  static const String bureaucratSubmit = 'Submit';
  static const String bureaucratReasonHint = 'Why do you need this app?';
  static const String bureaucratDurationHint = 'How long? (minutes)';
  static const String bureaucratCodeHint = '1-10 (1=lowest, 10=urgent)';

  static const String chaseTitle = 'Catch the Button';
  static const String chaseCounter = '0 / 100';
}
