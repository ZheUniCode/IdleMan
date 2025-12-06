// ============================================================================
// IDLEMAN v16.0 - HIVE SERVICE
// ============================================================================
// File: lib/core/services/hive_service.dart
// Purpose: Initialize and manage Hive local database boxes
// Philosophy: Local-First Ethics - all data stays on device
// ============================================================================

// Import Flutter foundation for debugPrint
import 'package:flutter/foundation.dart';

// Import Hive Flutter for local NoSQL database
import 'package:hive_flutter/hive_flutter.dart';

// Import path_provider to get the application documents directory
import 'package:path_provider/path_provider.dart';

// ============================================================================
// HIVE BOX NAMES
// ============================================================================
// Constants for all Hive box names used throughout the application
// Centralizing these prevents typos and makes refactoring easier
// ============================================================================
class HiveBoxNames {
  // -------------------------------------------------------------------------
  // Private constructor to prevent instantiation
  // This class is a namespace for static constants only
  // -------------------------------------------------------------------------
  HiveBoxNames._();

  // -------------------------------------------------------------------------
  // SETTINGS BOX - Stores user preferences and configuration
  // Contents: Theme preference, notification times, strict mode status, etc.
  // -------------------------------------------------------------------------
  static const String settings = 'settings';

  // -------------------------------------------------------------------------
  // STATS BOX - Stores usage statistics and time tracking data
  // Contents: Time reclaimed, session counts, streak data, etc.
  // Philosophy: "Time Reclaimed" (Positive), not "Time Wasted" (Negative)
  // -------------------------------------------------------------------------
  static const String stats = 'stats';

  // -------------------------------------------------------------------------
  // DIGEST BOX - Stores sanitized notification queue
  // Contents: Intercepted notifications from bounded apps
  // Philosophy: Zero-Knowledge - raw notification text never leaves device
  // -------------------------------------------------------------------------
  static const String digest = 'digest';

  // -------------------------------------------------------------------------
  // BOUNDARIES BOX - Stores app boundary configurations
  // Contents: Package names of bounded apps, time limits per app
  // -------------------------------------------------------------------------
  static const String boundaries = 'boundaries';

  // -------------------------------------------------------------------------
  // GARDEN BOX - Stores local cache of garden state
  // Contents: Cached garden data for offline access
  // Note: Primary source is Firestore; this is offline backup
  // -------------------------------------------------------------------------
  static const String garden = 'garden';
}

// ============================================================================
// HIVE SERVICE
// ============================================================================
// Singleton service that manages all Hive database operations
// Provides centralized access to all boxes with logging
// ============================================================================
class HiveService {
  // -------------------------------------------------------------------------
  // Private constructor for singleton pattern
  // -------------------------------------------------------------------------
  HiveService._internal();

  // -------------------------------------------------------------------------
  // Singleton instance - only one HiveService exists in the app
  // -------------------------------------------------------------------------
  static final HiveService _instance = HiveService._internal();

  // -------------------------------------------------------------------------
  // Factory constructor returns the singleton instance
  // -------------------------------------------------------------------------
  factory HiveService() {
    // Log that singleton instance is being accessed
    debugPrint('[HiveService::factory] Returning singleton instance.');
    
    // Return the singleton instance
    return _instance;
  }

  // -------------------------------------------------------------------------
  // Private flag to track initialization status
  // Prevents double initialization which would cause errors
  // -------------------------------------------------------------------------
  bool _isInitialized = false;

  // -------------------------------------------------------------------------
  // GETTER: Check if Hive has been initialized
  // -------------------------------------------------------------------------
  bool get isInitialized => _isInitialized;

  // -------------------------------------------------------------------------
  // Private references to opened boxes
  // Stored as instance variables for quick access after initialization
  // -------------------------------------------------------------------------
  Box<dynamic>? _settingsBox;
  Box<dynamic>? _statsBox;
  Box<dynamic>? _digestBox;
  Box<dynamic>? _boundariesBox;
  Box<dynamic>? _gardenBox;

  // -------------------------------------------------------------------------
  // INITIALIZE - Must be called before any other Hive operations
  // Opens all required boxes and prepares the database
  // -------------------------------------------------------------------------
  Future<void> initialize() async {
    // Log entry into the initialization method
    debugPrint('[HiveService::initialize] ================================');
    debugPrint('[HiveService::initialize] Starting Hive initialization...');
    debugPrint('[HiveService::initialize] ================================');

    // Check if already initialized to prevent double initialization
    if (_isInitialized) {
      // Log that initialization is being skipped
      debugPrint('[HiveService::initialize] Already initialized. Skipping.');
      
      // Return early - nothing to do
      return;
    }

    // Log that we're getting the application documents directory
    debugPrint('[HiveService::initialize] Getting app documents directory...');
    
    // Get the application documents directory for storing Hive data
    final appDocDir = await getApplicationDocumentsDirectory();
    
    // Log the directory path
    debugPrint('[HiveService::initialize] App documents directory: ${appDocDir.path}');

    // Log that we're initializing Hive Flutter
    debugPrint('[HiveService::initialize] Initializing Hive Flutter...');
    
    // Initialize Hive with the app documents directory
    await Hive.initFlutter(appDocDir.path);
    
    // Log successful Hive initialization
    debugPrint('[HiveService::initialize] Hive Flutter initialized successfully.');

    // Open all required boxes
    await _openAllBoxes();

    // Set initialization flag to true
    _isInitialized = true;
    
    // Log completion of initialization
    debugPrint('[HiveService::initialize] ================================');
    debugPrint('[HiveService::initialize] Hive initialization complete!');
    debugPrint('[HiveService::initialize] ================================');
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Open all Hive boxes
  // Called during initialization to prepare all storage boxes
  // -------------------------------------------------------------------------
  Future<void> _openAllBoxes() async {
    // Log entry into the method
    debugPrint('[HiveService::_openAllBoxes] Opening all Hive boxes...');

    // Open the settings box
    debugPrint('[HiveService::_openAllBoxes] Opening "${HiveBoxNames.settings}" box...');
    _settingsBox = await Hive.openBox(HiveBoxNames.settings);
    debugPrint('[HiveService::_openAllBoxes] "${HiveBoxNames.settings}" box opened. Keys: ${_settingsBox?.keys.length ?? 0}');

    // Open the stats box
    debugPrint('[HiveService::_openAllBoxes] Opening "${HiveBoxNames.stats}" box...');
    _statsBox = await Hive.openBox(HiveBoxNames.stats);
    debugPrint('[HiveService::_openAllBoxes] "${HiveBoxNames.stats}" box opened. Keys: ${_statsBox?.keys.length ?? 0}');

    // Open the digest box
    debugPrint('[HiveService::_openAllBoxes] Opening "${HiveBoxNames.digest}" box...');
    _digestBox = await Hive.openBox(HiveBoxNames.digest);
    debugPrint('[HiveService::_openAllBoxes] "${HiveBoxNames.digest}" box opened. Keys: ${_digestBox?.keys.length ?? 0}');

    // Open the boundaries box
    debugPrint('[HiveService::_openAllBoxes] Opening "${HiveBoxNames.boundaries}" box...');
    _boundariesBox = await Hive.openBox(HiveBoxNames.boundaries);
    debugPrint('[HiveService::_openAllBoxes] "${HiveBoxNames.boundaries}" box opened. Keys: ${_boundariesBox?.keys.length ?? 0}');

    // Open the garden box
    debugPrint('[HiveService::_openAllBoxes] Opening "${HiveBoxNames.garden}" box...');
    _gardenBox = await Hive.openBox(HiveBoxNames.garden);
    debugPrint('[HiveService::_openAllBoxes] "${HiveBoxNames.garden}" box opened. Keys: ${_gardenBox?.keys.length ?? 0}');

    // Log completion
    debugPrint('[HiveService::_openAllBoxes] All boxes opened successfully.');
  }

  // -------------------------------------------------------------------------
  // SETTINGS BOX - Getter for settings box
  // Returns the opened settings box or throws if not initialized
  // -------------------------------------------------------------------------
  Box<dynamic> get settingsBox {
    // Log access to settings box
    debugPrint('[HiveService::settingsBox] Accessing settings box...');
    
    // Check if initialized
    if (!_isInitialized || _settingsBox == null) {
      // Log error
      debugPrint('[HiveService::settingsBox] ERROR: Hive not initialized!');
      
      // Throw exception with helpful message
      throw StateError('HiveService not initialized. Call initialize() first.');
    }
    
    // Log successful access
    debugPrint('[HiveService::settingsBox] Settings box accessed successfully.');
    
    // Return the box
    return _settingsBox!;
  }

  // -------------------------------------------------------------------------
  // STATS BOX - Getter for stats box
  // Returns the opened stats box or throws if not initialized
  // -------------------------------------------------------------------------
  Box<dynamic> get statsBox {
    // Log access to stats box
    debugPrint('[HiveService::statsBox] Accessing stats box...');
    
    // Check if initialized
    if (!_isInitialized || _statsBox == null) {
      // Log error
      debugPrint('[HiveService::statsBox] ERROR: Hive not initialized!');
      
      // Throw exception with helpful message
      throw StateError('HiveService not initialized. Call initialize() first.');
    }
    
    // Log successful access
    debugPrint('[HiveService::statsBox] Stats box accessed successfully.');
    
    // Return the box
    return _statsBox!;
  }

  // -------------------------------------------------------------------------
  // DIGEST BOX - Getter for digest box
  // Returns the opened digest box or throws if not initialized
  // -------------------------------------------------------------------------
  Box<dynamic> get digestBox {
    // Log access to digest box
    debugPrint('[HiveService::digestBox] Accessing digest box...');
    
    // Check if initialized
    if (!_isInitialized || _digestBox == null) {
      // Log error
      debugPrint('[HiveService::digestBox] ERROR: Hive not initialized!');
      
      // Throw exception with helpful message
      throw StateError('HiveService not initialized. Call initialize() first.');
    }
    
    // Log successful access
    debugPrint('[HiveService::digestBox] Digest box accessed successfully.');
    
    // Return the box
    return _digestBox!;
  }

  // -------------------------------------------------------------------------
  // BOUNDARIES BOX - Getter for boundaries box
  // Returns the opened boundaries box or throws if not initialized
  // -------------------------------------------------------------------------
  Box<dynamic> get boundariesBox {
    // Log access to boundaries box
    debugPrint('[HiveService::boundariesBox] Accessing boundaries box...');
    
    // Check if initialized
    if (!_isInitialized || _boundariesBox == null) {
      // Log error
      debugPrint('[HiveService::boundariesBox] ERROR: Hive not initialized!');
      
      // Throw exception with helpful message
      throw StateError('HiveService not initialized. Call initialize() first.');
    }
    
    // Log successful access
    debugPrint('[HiveService::boundariesBox] Boundaries box accessed successfully.');
    
    // Return the box
    return _boundariesBox!;
  }

  // -------------------------------------------------------------------------
  // GARDEN BOX - Getter for garden box
  // Returns the opened garden box or throws if not initialized
  // -------------------------------------------------------------------------
  Box<dynamic> get gardenBox {
    // Log access to garden box
    debugPrint('[HiveService::gardenBox] Accessing garden box...');
    
    // Check if initialized
    if (!_isInitialized || _gardenBox == null) {
      // Log error
      debugPrint('[HiveService::gardenBox] ERROR: Hive not initialized!');
      
      // Throw exception with helpful message
      throw StateError('HiveService not initialized. Call initialize() first.');
    }
    
    // Log successful access
    debugPrint('[HiveService::gardenBox] Garden box accessed successfully.');
    
    // Return the box
    return _gardenBox!;
  }

  // =========================================================================
  // GENERIC READ/WRITE OPERATIONS WITH LOGGING
  // =========================================================================

  // -------------------------------------------------------------------------
  // PUT - Write a value to a specific box
  // Logs the operation for debugging
  // -------------------------------------------------------------------------
  Future<void> put({
    required String boxName,
    required String key,
    required dynamic value,
  }) async {
    // Log entry into the method
    debugPrint('[HiveService::put] Started. Box: $boxName, Key: $key');
    debugPrint('[HiveService::put] Value type: ${value.runtimeType}');

    // Get the appropriate box
    final box = _getBoxByName(boxName);
    
    // Write the value to the box
    await box.put(key, value);
    
    // Log successful write
    debugPrint('[HiveService::put] Value written successfully.');
    debugPrint('[HiveService::put] Completed.');
  }

  // -------------------------------------------------------------------------
  // GET - Read a value from a specific box
  // Logs the operation for debugging
  // -------------------------------------------------------------------------
  T? get<T>({
    required String boxName,
    required String key,
    T? defaultValue,
  }) {
    // Log entry into the method
    debugPrint('[HiveService::get] Started. Box: $boxName, Key: $key');

    // Get the appropriate box
    final box = _getBoxByName(boxName);
    
    // Read the value from the box
    final value = box.get(key, defaultValue: defaultValue) as T?;
    
    // Log the retrieved value
    debugPrint('[HiveService::get] Value retrieved: $value');
    debugPrint('[HiveService::get] Completed.');
    
    // Return the value
    return value;
  }

  // -------------------------------------------------------------------------
  // DELETE - Remove a value from a specific box
  // Logs the operation for debugging
  // -------------------------------------------------------------------------
  Future<void> delete({
    required String boxName,
    required String key,
  }) async {
    // Log entry into the method
    debugPrint('[HiveService::delete] Started. Box: $boxName, Key: $key');

    // Get the appropriate box
    final box = _getBoxByName(boxName);
    
    // Delete the value from the box
    await box.delete(key);
    
    // Log successful deletion
    debugPrint('[HiveService::delete] Key deleted successfully.');
    debugPrint('[HiveService::delete] Completed.');
  }

  // -------------------------------------------------------------------------
  // CLEAR BOX - Remove all values from a specific box
  // Logs the operation for debugging
  // -------------------------------------------------------------------------
  Future<void> clearBox(String boxName) async {
    // Log entry into the method
    debugPrint('[HiveService::clearBox] Started. Box: $boxName');

    // Get the appropriate box
    final box = _getBoxByName(boxName);
    
    // Get the count before clearing for logging
    final countBefore = box.keys.length;
    debugPrint('[HiveService::clearBox] Keys before clear: $countBefore');
    
    // Clear all values from the box
    await box.clear();
    
    // Log successful clear
    debugPrint('[HiveService::clearBox] Box cleared successfully.');
    debugPrint('[HiveService::clearBox] Completed.');
  }

  // -------------------------------------------------------------------------
  // PRIVATE: Get box by name
  // Helper method to get the correct box reference by name
  // -------------------------------------------------------------------------
  Box<dynamic> _getBoxByName(String boxName) {
    // Log the box lookup
    debugPrint('[HiveService::_getBoxByName] Looking up box: $boxName');

    // Switch on box name to return the correct box
    switch (boxName) {
      // Return settings box
      case HiveBoxNames.settings:
        return settingsBox;
      
      // Return stats box
      case HiveBoxNames.stats:
        return statsBox;
      
      // Return digest box
      case HiveBoxNames.digest:
        return digestBox;
      
      // Return boundaries box
      case HiveBoxNames.boundaries:
        return boundariesBox;
      
      // Return garden box
      case HiveBoxNames.garden:
        return gardenBox;
      
      // Unknown box name - throw error
      default:
        debugPrint('[HiveService::_getBoxByName] ERROR: Unknown box name: $boxName');
        throw ArgumentError('Unknown box name: $boxName');
    }
  }

  // =========================================================================
  // SETTINGS CONVENIENCE METHODS
  // =========================================================================

  // -------------------------------------------------------------------------
  // SAVE SETTING - Convenience method to save a setting
  // -------------------------------------------------------------------------
  Future<void> saveSetting(String key, dynamic value) async {
    // Log entry into the method
    debugPrint('[HiveService::saveSetting] Started. Key: $key, Value: $value');
    
    // Use the generic put method
    await put(boxName: HiveBoxNames.settings, key: key, value: value);
    
    // Log completion
    debugPrint('[HiveService::saveSetting] Completed.');
  }

  // -------------------------------------------------------------------------
  // GET SETTING - Convenience method to get a setting
  // -------------------------------------------------------------------------
  T? getSetting<T>(String key, {T? defaultValue}) {
    // Log entry into the method
    debugPrint('[HiveService::getSetting] Started. Key: $key');
    
    // Use the generic get method
    final value = get<T>(
      boxName: HiveBoxNames.settings,
      key: key,
      defaultValue: defaultValue,
    );
    
    // Log completion
    debugPrint('[HiveService::getSetting] Completed. Value: $value');
    
    // Return the value
    return value;
  }

  // =========================================================================
  // CLEANUP
  // =========================================================================

  // -------------------------------------------------------------------------
  // CLOSE ALL BOXES - Call when app is shutting down
  // -------------------------------------------------------------------------
  Future<void> closeAll() async {
    // Log entry into the method
    debugPrint('[HiveService::closeAll] Started. Closing all Hive boxes...');
    
    // Close all Hive boxes
    await Hive.close();
    
    // Reset initialization flag
    _isInitialized = false;
    
    // Clear box references
    _settingsBox = null;
    _statsBox = null;
    _digestBox = null;
    _boundariesBox = null;
    _gardenBox = null;
    
    // Log completion
    debugPrint('[HiveService::closeAll] All boxes closed. Completed.');
  }
}
