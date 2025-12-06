// ============================================================================
// IDLEMAN v16.0 - APP USAGE MODEL
// ============================================================================
// File: lib/features/reflection/models/app_usage_model.dart
// Purpose: Data model for app usage statistics
// Philosophy: "Reflection" not "Surveillance" - users reflect on their habits
// ============================================================================

// Import Flutter foundation for debugPrint and Uint8List
import 'package:flutter/foundation.dart';

// ============================================================================
// APP USAGE MODEL
// ============================================================================
// Represents a single app's usage data for the Reflection Engine
// Stores app metadata and usage time without judgment
// ============================================================================
class AppUsageModel {
  // -------------------------------------------------------------------------
  // PACKAGE NAME - Unique identifier for the app
  // Example: "com.instagram.android", "com.tiktok.android"
  // -------------------------------------------------------------------------
  final String packageName;

  // -------------------------------------------------------------------------
  // APP NAME - Human-readable display name
  // Example: "Instagram", "TikTok"
  // -------------------------------------------------------------------------
  final String appName;

  // -------------------------------------------------------------------------
  // USAGE TIME - Total usage time in milliseconds for the current period
  // Philosophy: This is "energy spent" - neutral, not judgmental
  // -------------------------------------------------------------------------
  final int usageTimeMs;

  // -------------------------------------------------------------------------
  // APP ICON - Raw bytes of the app icon
  // Stored as Uint8List to allow display in Flutter Image widget
  // Optional because icon may not always be available
  // -------------------------------------------------------------------------
  final Uint8List? appIcon;

  // -------------------------------------------------------------------------
  // IS BOUNDED - Whether the user has set a boundary on this app
  // True = User has chosen to be mindful about this app
  // -------------------------------------------------------------------------
  final bool isBounded;

  // -------------------------------------------------------------------------
  // LAST USED - Timestamp of last use
  // Used for sorting and displaying "recent" apps
  // -------------------------------------------------------------------------
  final DateTime? lastUsed;

  // -------------------------------------------------------------------------
  // IS SYSTEM APP - Whether this is a system/pre-installed app
  // Used for the Hidden Whitelist filter logic
  // -------------------------------------------------------------------------
  final bool isSystemApp;

  // -------------------------------------------------------------------------
  // CATEGORY - App category (if available)
  // Example: "Social", "Games", "Productivity"
  // Used for filtering in the Reflection UI
  // -------------------------------------------------------------------------
  final String? category;

  // -------------------------------------------------------------------------
  // CONSTRUCTOR
  // All properties are final (immutable) for safety
  // -------------------------------------------------------------------------
  const AppUsageModel({
    // Required: package name is the unique identifier
    required this.packageName,
    // Required: app name for display
    required this.appName,
    // Required: usage time in milliseconds
    required this.usageTimeMs,
    // Optional: app icon bytes
    this.appIcon,
    // Default: not bounded initially
    this.isBounded = false,
    // Optional: last used timestamp
    this.lastUsed,
    // Default: assume not a system app
    this.isSystemApp = false,
    // Optional: category
    this.category,
  });

  // -------------------------------------------------------------------------
  // GETTER: Usage time formatted as Duration
  // Converts milliseconds to a Duration object for easy manipulation
  // -------------------------------------------------------------------------
  Duration get usageDuration {
    // Log the conversion
    debugPrint('[AppUsageModel::usageDuration] Converting $usageTimeMs ms to Duration.');
    
    // Create Duration from milliseconds
    final duration = Duration(milliseconds: usageTimeMs);
    
    // Log the result
    debugPrint('[AppUsageModel::usageDuration] Duration: $duration');
    
    // Return the duration
    return duration;
  }

  // -------------------------------------------------------------------------
  // GETTER: Usage time formatted as human-readable string
  // Example: "2h 34m" or "45m" or "< 1m"
  // Philosophy: Neutral presentation, no judgment words
  // -------------------------------------------------------------------------
  String get usageTimeFormatted {
    // Log entry into the getter
    debugPrint('[AppUsageModel::usageTimeFormatted] Formatting usage time for $appName.');
    
    // Get the duration
    final duration = usageDuration;
    
    // Extract hours and minutes
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    // Log extracted values
    debugPrint('[AppUsageModel::usageTimeFormatted] Hours: $hours, Minutes: $minutes');
    
    // Build the formatted string
    String formatted;
    
    // If usage is less than 1 minute
    if (duration.inMinutes < 1) {
      // Show "< 1m" for very short usage
      formatted = '< 1m';
    }
    // If usage is less than 1 hour
    else if (hours < 1) {
      // Show only minutes
      formatted = '${minutes}m';
    }
    // If usage is 1 hour or more
    else {
      // Show hours and minutes
      formatted = '${hours}h ${minutes}m';
    }
    
    // Log the formatted result
    debugPrint('[AppUsageModel::usageTimeFormatted] Formatted: $formatted');
    
    // Return the formatted string
    return formatted;
  }

  // -------------------------------------------------------------------------
  // GETTER: Check if this app is "reflectable" (should appear in the list)
  // Filters out system apps and critical apps per the Hidden Whitelist logic
  // -------------------------------------------------------------------------
  bool get isReflectable {
    // Log entry into the getter
    debugPrint('[AppUsageModel::isReflectable] Checking if $packageName is reflectable.');
    
    // List of packages that should NEVER appear in the Reflection list
    // These are critical system apps that users should not block
    const excludedPackages = [
      // Android Settings - users need access to device settings
      'com.android.settings',
      // Google Play Store - needed for app updates
      'com.android.vending',
      // Phone Dialer - emergency calls
      'com.google.android.dialer',
      'com.android.dialer',
      // Contacts - needed for communication
      'com.android.contacts',
      'com.google.android.contacts',
      // Messages - needed for SMS
      'com.android.messaging',
      'com.google.android.apps.messaging',
      // Camera - might be needed for emergencies
      'com.android.camera',
      'com.google.android.camera',
      // Clock/Alarm - users need their alarms
      'com.android.deskclock',
      'com.google.android.deskclock',
      // Calculator - basic utility
      'com.android.calculator2',
      'com.google.android.calculator',
      // IdleMan itself - prevent blocking the blocker
      'com.idleman',
      'com.idleman.android',
    ];
    
    // Check if package is in the excluded list
    if (excludedPackages.contains(packageName)) {
      // Log that this app is excluded
      debugPrint('[AppUsageModel::isReflectable] $packageName is EXCLUDED (critical app).');
      
      // Return false - not reflectable
      return false;
    }
    
    // Check if it's a system app that hasn't been updated
    // Updated system apps (like Chrome) should still be reflectable
    if (isSystemApp) {
      // Log that this is a system app
      debugPrint('[AppUsageModel::isReflectable] $packageName is a system app.');
      
      // For now, include system apps that have significant usage
      // This allows users to reflect on pre-installed social apps
      if (usageTimeMs > 60000) { // More than 1 minute of usage
        debugPrint('[AppUsageModel::isReflectable] $packageName has significant usage, including.');
        return true;
      }
      
      // Exclude low-usage system apps
      debugPrint('[AppUsageModel::isReflectable] $packageName excluded (low-usage system app).');
      return false;
    }
    
    // Log that this app is reflectable
    debugPrint('[AppUsageModel::isReflectable] $packageName IS reflectable.');
    
    // Return true - this app should appear in the Reflection list
    return true;
  }

  // -------------------------------------------------------------------------
  // COPY WITH - Creates a copy with modified properties
  // Used for immutable state updates
  // -------------------------------------------------------------------------
  AppUsageModel copyWith({
    String? packageName,
    String? appName,
    int? usageTimeMs,
    Uint8List? appIcon,
    bool? isBounded,
    DateTime? lastUsed,
    bool? isSystemApp,
    String? category,
  }) {
    // Log entry into the method
    debugPrint('[AppUsageModel::copyWith] Creating copy of ${this.appName}.');
    
    // Create and return a new instance with updated values
    final copy = AppUsageModel(
      // Use provided value or fall back to current value
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      usageTimeMs: usageTimeMs ?? this.usageTimeMs,
      appIcon: appIcon ?? this.appIcon,
      isBounded: isBounded ?? this.isBounded,
      lastUsed: lastUsed ?? this.lastUsed,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      category: category ?? this.category,
    );
    
    // Log the created copy
    debugPrint('[AppUsageModel::copyWith] Copy created successfully.');
    
    // Return the copy
    return copy;
  }

  // -------------------------------------------------------------------------
  // TO STRING - String representation for debugging
  // -------------------------------------------------------------------------
  @override
  String toString() {
    return 'AppUsageModel(packageName: $packageName, appName: $appName, '
        'usageTime: $usageTimeFormatted, isBounded: $isBounded)';
  }

  // -------------------------------------------------------------------------
  // EQUALITY - Compare two AppUsageModel instances
  // Two models are equal if they have the same package name
  // -------------------------------------------------------------------------
  @override
  bool operator ==(Object other) {
    // Check if same instance
    if (identical(this, other)) return true;
    
    // Check if same type and same package name
    return other is AppUsageModel && other.packageName == packageName;
  }

  // -------------------------------------------------------------------------
  // HASH CODE - Hash based on package name
  // Consistent with equality operator
  // -------------------------------------------------------------------------
  @override
  int get hashCode => packageName.hashCode;
}

// ============================================================================
// APP CATEGORY ENUM
// ============================================================================
// Predefined categories for filtering apps in the Reflection UI
// ============================================================================
enum AppCategory {
  // -------------------------------------------------------------------------
  // ALL - Show all apps (no filter)
  // -------------------------------------------------------------------------
  all('All'),

  // -------------------------------------------------------------------------
  // FOCUS THIEVES - Apps sorted by usage time (descending)
  // Philosophy: "Focus Thieves" is playful, not judgmental
  // -------------------------------------------------------------------------
  focusThieves('Focus Thieves'),

  // -------------------------------------------------------------------------
  // SOCIAL - Social media apps
  // Instagram, TikTok, Facebook, Twitter, Snapchat, etc.
  // -------------------------------------------------------------------------
  social('Social'),

  // -------------------------------------------------------------------------
  // GAMES - Gaming apps
  // Detected via ApplicationInfo.FLAG_IS_GAME or category
  // -------------------------------------------------------------------------
  games('Games'),

  // -------------------------------------------------------------------------
  // ENTERTAINMENT - Video and streaming apps
  // YouTube, Netflix, Twitch, etc.
  // -------------------------------------------------------------------------
  entertainment('Entertainment'),

  // -------------------------------------------------------------------------
  // NEW ARRIVALS - Apps installed in the last 7 days
  // Helps users notice new potential distractions
  // -------------------------------------------------------------------------
  newArrivals('New Arrivals');

  // -------------------------------------------------------------------------
  // DISPLAY NAME - Human-readable label for the category
  // -------------------------------------------------------------------------
  final String displayName;

  // -------------------------------------------------------------------------
  // CONSTRUCTOR
  // -------------------------------------------------------------------------
  const AppCategory(this.displayName);
}

// ============================================================================
// USAGE STATS PERIOD
// ============================================================================
// Time periods for usage statistics queries
// ============================================================================
enum UsageStatsPeriod {
  // -------------------------------------------------------------------------
  // TODAY - Usage stats for the current day
  // -------------------------------------------------------------------------
  today('Today'),

  // -------------------------------------------------------------------------
  // YESTERDAY - Usage stats for the previous day
  // -------------------------------------------------------------------------
  yesterday('Yesterday'),

  // -------------------------------------------------------------------------
  // THIS WEEK - Usage stats for the current week
  // -------------------------------------------------------------------------
  thisWeek('This Week'),

  // -------------------------------------------------------------------------
  // THIS MONTH - Usage stats for the current month
  // -------------------------------------------------------------------------
  thisMonth('This Month');

  // -------------------------------------------------------------------------
  // DISPLAY NAME - Human-readable label for the period
  // -------------------------------------------------------------------------
  final String displayName;

  // -------------------------------------------------------------------------
  // CONSTRUCTOR
  // -------------------------------------------------------------------------
  const UsageStatsPeriod(this.displayName);
}
