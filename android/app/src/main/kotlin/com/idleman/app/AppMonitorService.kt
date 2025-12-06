// ============================================================================
// IDLEMAN v16.0 - APP MONITOR SERVICE (KOTLIN NATIVE)
// ============================================================================
// File: android/app/src/main/kotlin/com/idleman/app/AppMonitorService.kt
// Purpose: AccessibilityService for detecting bounded app launches
// Philosophy: "The Detector" - Gentle awareness, not surveillance
// ============================================================================

package com.idleman.app

// ============================================================================
// IMPORTS
// ============================================================================

// Android AccessibilityService for monitoring app events
import android.accessibilityservice.AccessibilityService

// Context for SharedPreferences access
import android.content.Context

// Intent for launching overlay activity
import android.content.Intent

// Logging utilities
import android.util.Log

// Accessibility events from the system
import android.view.accessibility.AccessibilityEvent

// Flutter MethodChannel for communication with Dart
import io.flutter.plugin.common.MethodChannel

// ============================================================================
// APP MONITOR SERVICE
// ============================================================================
// The "Detector" component of IdleMan's Mindful Defense System
// Monitors window changes and detects when bounded apps are launched
// Philosophy: We don't "block" apps, we create "awareness moments"
// ============================================================================
class AppMonitorService : AccessibilityService() {

    // ========================================================================
    // COMPANION OBJECT (STATIC MEMBERS)
    // ========================================================================
    companion object {
        // Tag for all log messages from this service
        private const val TAG = "IdleMan::AppMonitorService"
        
        // MethodChannel name for communication with Flutter
        const val CHANNEL_NAME = "com.idleman/app_monitor"
        
        // Singleton instance reference for external access
        var instance: AppMonitorService? = null
        
        // MethodChannel instance set by MainActivity
        var methodChannel: MethodChannel? = null
        
        // Timestamp of last service creation (prevents restart loops)
        private var lastCreateTime = 0L
        
        // Minimum time between service creations (1 second)
        private const val MIN_CREATE_INTERVAL_MS = 1000L
    }

    // ========================================================================
    // INSTANCE VARIABLES
    // ========================================================================
    
    // Set of package names that have boundaries set by the user
    // Philosophy: These are "bounded" not "blocked" - compassionate language
    private val boundedPackages = mutableSetOf<String>()
    
    // Flag to track if the service has been fully initialized
    private var isInitialized = false
    
    // Map of packages with temporary access (package name -> expiry timestamp)
    // Granted after user completes a "Mindful Practice" task
    private val temporaryAccessMap = mutableMapOf<String, Long>()
    
    // Default temporary access duration (5 minutes in milliseconds)
    private val DEFAULT_ACCESS_DURATION_MS = 5 * 60 * 1000L

    // ========================================================================
    // LIFECYCLE: onCreate
    // ========================================================================
    // Called when the service is first created
    // Initializes the service and loads bounded apps from storage
    // ========================================================================
    override fun onCreate() {
        // Call parent implementation
        super.onCreate()
        
        // Log entry into onCreate
        Log.d(TAG, "[onCreate] ========================================")
        Log.d(TAG, "[onCreate] Service creation started.")
        Log.d(TAG, "[onCreate] ========================================")
        
        // Get current timestamp for restart loop protection
        val currentTime = System.currentTimeMillis()
        
        // Log the timing check
        Log.d(TAG, "[onCreate] Current time: $currentTime")
        Log.d(TAG, "[onCreate] Last create time: $lastCreateTime")
        Log.d(TAG, "[onCreate] Time since last create: ${currentTime - lastCreateTime}ms")
        
        // Check for rapid restart loop (service being recreated too quickly)
        if (instance != null && currentTime - lastCreateTime < MIN_CREATE_INTERVAL_MS) {
            // Log the warning
            Log.w(TAG, "[onCreate] WARNING: Service recreation too fast!")
            Log.w(TAG, "[onCreate] Possible restart loop detected. Skipping duplicate onCreate.")
            
            // Return early to prevent duplicate initialization
            return
        }
        
        // Update the last create timestamp
        lastCreateTime = currentTime
        Log.d(TAG, "[onCreate] Updated lastCreateTime to: $lastCreateTime")
        
        // Set the singleton instance reference
        instance = this
        Log.d(TAG, "[onCreate] Singleton instance set.")
        
        // Initialize only if not already initialized
        if (!isInitialized) {
            // Log initialization start
            Log.d(TAG, "[onCreate] Beginning first-time initialization...")
            
            // Load bounded apps from SharedPreferences
            loadBoundedApps()
            
            // Set initialization flag
            isInitialized = true
            
            // Log successful initialization
            Log.d(TAG, "[onCreate] Initialization complete.")
            Log.d(TAG, "[onCreate] Loaded ${boundedPackages.size} bounded apps.")
            Log.d(TAG, "[onCreate] Bounded packages: $boundedPackages")
        } else {
            // Log that we're skipping initialization
            Log.d(TAG, "[onCreate] Already initialized. Skipping reload.")
        }
        
        // Log exit from onCreate
        Log.d(TAG, "[onCreate] ========================================")
        Log.d(TAG, "[onCreate] Service creation completed.")
        Log.d(TAG, "[onCreate] ========================================")
    }

    // ========================================================================
    // LIFECYCLE: onServiceConnected
    // ========================================================================
    // Called when the service is connected to the accessibility framework
    // This is where the service becomes active and can receive events
    // ========================================================================
    override fun onServiceConnected() {
        // Call parent implementation
        super.onServiceConnected()
        
        // Log entry into onServiceConnected
        Log.d(TAG, "[onServiceConnected] ========================================")
        Log.d(TAG, "[onServiceConnected] AccessibilityService connected to system.")
        Log.d(TAG, "[onServiceConnected] ========================================")
        
        // Safety mechanism: Clear any stale overlay flags on service start
        // This prevents the overlay from being stuck on from a previous session
        Log.d(TAG, "[onServiceConnected] Clearing stale overlay state...")
        
        // Get SharedPreferences
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        
        // Clear the overlay active flag
        prefs.edit().putBoolean("is_overlay_active", false).apply()
        
        // Log the safety reset
        Log.d(TAG, "[onServiceConnected] Overlay state cleared. Ready for monitoring.")
        Log.d(TAG, "[onServiceConnected] ========================================")
    }

    // ========================================================================
    // EVENT HANDLER: onAccessibilityEvent
    // ========================================================================
    // Called when an accessibility event occurs in the system
    // We specifically watch for TYPE_WINDOW_STATE_CHANGED events
    // ========================================================================
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Check if event is null
        if (event == null) {
            // Log and return early
            Log.v(TAG, "[onAccessibilityEvent] Received null event. Ignoring.")
            return
        }
        
        // Only process window state changed events
        // These indicate a new app window has come to the foreground
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            // Extract the package name from the event
            val packageName = event.packageName?.toString()
            
            // Check if package name is valid
            if (packageName.isNullOrEmpty()) {
                // Log and return early
                Log.v(TAG, "[onAccessibilityEvent] Window changed but package name is null/empty.")
                return
            }
            
            // Filter out system UI and Android framework packages
            // These should never trigger boundaries
            if (packageName == "android" || packageName == "com.android.systemui") {
                // Log and return early (verbose level to reduce log spam)
                Log.v(TAG, "[onAccessibilityEvent] Ignoring system package: $packageName")
                return
            }
            
            // Log the detected window change
            Log.d(TAG, "[onAccessibilityEvent] Window state changed to: $packageName")
            
            // Check if this app has a boundary set
            if (isAppBounded(packageName)) {
                // Log the boundary detection
                Log.i(TAG, "[onAccessibilityEvent] ========================================")
                Log.i(TAG, "[onAccessibilityEvent] BOUNDED APP DETECTED: $packageName")
                Log.i(TAG, "[onAccessibilityEvent] Initiating awareness moment...")
                Log.i(TAG, "[onAccessibilityEvent] ========================================")
                
                // Handle the bounded app (show overlay)
                handleBoundedApp(packageName)
            }
        }
    }

    // ========================================================================
    // LIFECYCLE: onInterrupt
    // ========================================================================
    // Called when the system wants to interrupt the service
    // Required by AccessibilityService but we don't need to do anything special
    // ========================================================================
    override fun onInterrupt() {
        // Log the interruption
        Log.w(TAG, "[onInterrupt] Service interrupted by system.")
    }

    // ========================================================================
    // LIFECYCLE: onDestroy
    // ========================================================================
    // Called when the service is being destroyed
    // Clean up singleton reference
    // ========================================================================
    override fun onDestroy() {
        // Log entry into onDestroy
        Log.d(TAG, "[onDestroy] ========================================")
        Log.d(TAG, "[onDestroy] Service destruction started.")
        
        // Clear singleton instance
        instance = null
        Log.d(TAG, "[onDestroy] Singleton instance cleared.")
        
        // Call parent implementation
        super.onDestroy()
        
        // Log completion
        Log.d(TAG, "[onDestroy] Service destruction completed.")
        Log.d(TAG, "[onDestroy] ========================================")
    }

    // ========================================================================
    // PRIVATE: isAppBounded
    // ========================================================================
    // Check if an app package has a boundary set by the user
    // Also checks for temporary access grants from completing tasks
    // ========================================================================
    private fun isAppBounded(packageName: String): Boolean {
        // Log entry into method
        Log.d(TAG, "[isAppBounded] Checking boundary status for: $packageName")
        
        // Get current timestamp for temporary access check
        val currentTime = System.currentTimeMillis()
        
        // Check if this app has temporary access (from completing a Mindful Practice)
        val accessExpiry = temporaryAccessMap[packageName]
        
        // Log the temporary access check
        Log.d(TAG, "[isAppBounded] Temporary access expiry: $accessExpiry")
        
        // If temporary access exists and hasn't expired
        if (accessExpiry != null && currentTime < accessExpiry) {
            // Calculate remaining time
            val remainingMs = accessExpiry - currentTime
            val remainingSec = remainingMs / 1000
            
            // Log the active temporary access
            Log.d(TAG, "[isAppBounded] TEMPORARY ACCESS ACTIVE for $packageName")
            Log.d(TAG, "[isAppBounded] Time remaining: ${remainingSec}s")
            
            // Return false - app is not bounded during temporary access
            return false
        }
        
        // If temporary access has expired, remove it from the map
        if (accessExpiry != null) {
            // Log the expiration
            Log.d(TAG, "[isAppBounded] Temporary access EXPIRED for $packageName")
            
            // Remove from map
            temporaryAccessMap.remove(packageName)
        }
        
        // Check if package is in the bounded set
        val isBounded = boundedPackages.contains(packageName)
        
        // Log the result
        Log.d(TAG, "[isAppBounded] Result for $packageName: $isBounded")
        
        // Return the bounded status
        return isBounded
    }

    // ========================================================================
    // PRIVATE: handleBoundedApp
    // ========================================================================
    // Handle detection of a bounded app
    // Triggers the overlay to create an "awareness moment"
    // ========================================================================
    private fun handleBoundedApp(packageName: String) {
        // Log entry into method
        Log.d(TAG, "[handleBoundedApp] ========================================")
        Log.d(TAG, "[handleBoundedApp] Handling bounded app: $packageName")
        
        // SAFETY CHECK: Never create boundaries for ourselves!
        // This would create an infinite loop
        if (packageName == this.packageName) {
            Log.w(TAG, "[handleBoundedApp] SAFETY: Prevented self-boundary!")
            Log.w(TAG, "[handleBoundedApp] Package $packageName is our own app.")
            return
        }
        
        // SAFETY CHECK: Don't create boundaries for critical system apps
        // Users need access to these for device functionality and safety
        val criticalApps = setOf(
            // Our own app (double protection)
            applicationContext.packageName,
            
            // Device Settings - users must be able to access settings
            "com.android.settings",
            
            // Phone Dialer - emergency calls
            "com.android.phone",
            "com.android.dialer",
            "com.google.android.dialer",
            
            // Messaging - emergency communication
            "com.android.messaging",
            "com.google.android.apps.messaging",
            "com.android.mms",
            
            // Contacts - needed for calls
            "com.android.contacts",
            
            // System UI
            "android",
            "com.android.systemui",
            
            // Default launchers
            "com.google.android.apps.nexuslauncher",
            "com.android.launcher3",
            "com.android.launcher"
        )
        
        // Check if this is a critical app
        if (criticalApps.contains(packageName)) {
            Log.w(TAG, "[handleBoundedApp] SAFETY: Critical system app detected!")
            Log.w(TAG, "[handleBoundedApp] Package $packageName is whitelisted for safety.")
            return
        }
        
        // Log that safety checks passed
        Log.d(TAG, "[handleBoundedApp] Safety checks passed. Proceeding with overlay.")
        
        // Notify Flutter through MethodChannel (if available)
        try {
            // Log the method channel invocation
            Log.d(TAG, "[handleBoundedApp] Invoking Flutter method channel...")
            
            // Invoke the method with app info
            methodChannel?.invokeMethod("appBounded", mapOf(
                "packageName" to packageName,
                "timestamp" to System.currentTimeMillis()
            ))
            
            // Log success
            Log.d(TAG, "[handleBoundedApp] Flutter notified via method channel.")
            
        } catch (e: Exception) {
            // Log the error
            Log.e(TAG, "[handleBoundedApp] ERROR invoking method channel: ${e.message}")
        }
        
        // Store the bounded package for later reference (e.g., granting access after task)
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        prefs.edit().putString("last_bounded_package", packageName).apply()
        Log.d(TAG, "[handleBoundedApp] Stored last_bounded_package: $packageName")
        
        // Launch the overlay activity
        launchOverlay(packageName)
        
        // Log completion
        Log.d(TAG, "[handleBoundedApp] Handler completed.")
        Log.d(TAG, "[handleBoundedApp] ========================================")
    }

    // ========================================================================
    // PRIVATE: launchOverlay
    // ========================================================================
    // Launch the overlay activity to show the "Intent Check" UI
    // This creates the "awareness moment" before app access
    // ========================================================================
    private fun launchOverlay(packageName: String) {
        // Log entry into method
        Log.d(TAG, "[launchOverlay] Starting overlay launch for: $packageName")
        
        // Get SharedPreferences
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        
        // Set flag indicating overlay is active
        prefs.edit().putBoolean("is_overlay_active", true).apply()
        Log.d(TAG, "[launchOverlay] Set is_overlay_active flag to true.")
        
        try {
            // Determine the overlay route (default to intent_check for v16.0)
            val route = "/overlay/intent_check"
            Log.d(TAG, "[launchOverlay] Overlay route: $route")
            
            // Create intent for overlay activity
            val intent = Intent(this, OverlayActivity::class.java).apply {
                // Pass the route as an extra
                putExtra("route", route)
                
                // Pass the bounded package name
                putExtra("bounded_package", packageName)
                
                // Required flags for starting activity from service
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                
                // Clear any existing overlay activities
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            
            // Log the intent details
            Log.d(TAG, "[launchOverlay] Intent created with route: $route")
            Log.d(TAG, "[launchOverlay] Intent flags set. Starting activity...")
            
            // Start the overlay activity
            startActivity(intent)
            
            // Log success
            Log.d(TAG, "[launchOverlay] Overlay activity started successfully.")
            
        } catch (e: Exception) {
            // Log the error
            Log.e(TAG, "[launchOverlay] ERROR launching overlay: ${e.message}")
            Log.e(TAG, "[launchOverlay] Stack trace: ${e.stackTraceToString()}")
            
            // Clear the overlay flag since we failed
            prefs.edit().putBoolean("is_overlay_active", false).apply()
        }
    }

    // ========================================================================
    // PRIVATE: loadBoundedApps
    // ========================================================================
    // Load the list of bounded apps from SharedPreferences
    // Called during service initialization
    // ========================================================================
    private fun loadBoundedApps() {
        // Log entry into method
        Log.d(TAG, "[loadBoundedApps] Loading bounded apps from SharedPreferences...")
        
        // Get SharedPreferences
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        
        // Load the bounded apps set (empty set as default)
        val boundedSet = prefs.getStringSet("bounded_apps", emptySet()) ?: emptySet()
        
        // Log the loaded data
        Log.d(TAG, "[loadBoundedApps] Raw bounded set from prefs: $boundedSet")
        
        // Clear and update the bounded packages set
        boundedPackages.clear()
        boundedPackages.addAll(boundedSet)
        
        // Log the result
        Log.d(TAG, "[loadBoundedApps] Loaded ${boundedPackages.size} bounded apps.")
        Log.d(TAG, "[loadBoundedApps] Bounded packages: $boundedPackages")
    }

    // ========================================================================
    // PUBLIC: updateBoundedApps
    // ========================================================================
    // Update the list of bounded apps (called from Flutter via MethodChannel)
    // ========================================================================
    fun updateBoundedApps(packages: Set<String>) {
        // Log entry into method
        Log.d(TAG, "[updateBoundedApps] ========================================")
        Log.d(TAG, "[updateBoundedApps] Updating bounded apps list.")
        Log.d(TAG, "[updateBoundedApps] New packages: $packages")
        
        // Clear and update the set
        boundedPackages.clear()
        boundedPackages.addAll(packages)
        
        // Log the update
        Log.d(TAG, "[updateBoundedApps] Updated to ${boundedPackages.size} bounded apps.")
        Log.d(TAG, "[updateBoundedApps] Current bounded packages: $boundedPackages")
        Log.d(TAG, "[updateBoundedApps] ========================================")
        
        // Note: We don't save to SharedPreferences here
        // MainActivity handles persistence to avoid duplicate writes
    }

    // ========================================================================
    // PUBLIC: grantTemporaryAccess
    // ========================================================================
    // Grant temporary access to a bounded app
    // Called after user completes a "Mindful Practice" task
    // Philosophy: This is "earning space" not "bypassing blocks"
    // ========================================================================
    fun grantTemporaryAccess(packageName: String) {
        // Log entry into method
        Log.d(TAG, "[grantTemporaryAccess] ========================================")
        Log.d(TAG, "[grantTemporaryAccess] Granting temporary access for: $packageName")
        
        // Get the configured access duration from preferences
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        val durationMinutes = prefs.getInt("access_duration_minutes", 5)
        
        // Convert minutes to milliseconds
        val durationMs = durationMinutes * 60 * 1000L
        
        // Calculate expiry timestamp
        val expiryTime = System.currentTimeMillis() + durationMs
        
        // Log the grant details
        Log.d(TAG, "[grantTemporaryAccess] Duration: $durationMinutes minutes")
        Log.d(TAG, "[grantTemporaryAccess] Duration in ms: $durationMs")
        Log.d(TAG, "[grantTemporaryAccess] Expiry timestamp: $expiryTime")
        
        // Add to temporary access map
        temporaryAccessMap[packageName] = expiryTime
        
        // Log success
        Log.i(TAG, "[grantTemporaryAccess] ACCESS GRANTED: $packageName")
        Log.i(TAG, "[grantTemporaryAccess] Valid for $durationMinutes minutes.")
        Log.d(TAG, "[grantTemporaryAccess] ========================================")
    }

    // ========================================================================
    // PUBLIC: revokeTemporaryAccess
    // ========================================================================
    // Revoke temporary access for a bounded app
    // Can be called if user wants to re-enable boundary early
    // ========================================================================
    fun revokeTemporaryAccess(packageName: String) {
        // Log entry into method
        Log.d(TAG, "[revokeTemporaryAccess] Revoking temporary access for: $packageName")
        
        // Remove from map
        val removed = temporaryAccessMap.remove(packageName)
        
        // Log the result
        if (removed != null) {
            Log.d(TAG, "[revokeTemporaryAccess] Access revoked successfully.")
        } else {
            Log.d(TAG, "[revokeTemporaryAccess] No active access to revoke.")
        }
    }

    // ========================================================================
    // PUBLIC: getActiveTemporaryAccess
    // ========================================================================
    // Get list of all packages with active temporary access
    // Useful for displaying in UI
    // ========================================================================
    fun getActiveTemporaryAccess(): Map<String, Long> {
        // Log entry into method
        Log.d(TAG, "[getActiveTemporaryAccess] Getting active temporary access list.")
        
        // Get current timestamp
        val currentTime = System.currentTimeMillis()
        
        // Filter to only active (non-expired) entries
        val activeAccess = temporaryAccessMap.filter { (_, expiry) ->
            currentTime < expiry
        }
        
        // Log the result
        Log.d(TAG, "[getActiveTemporaryAccess] Active access count: ${activeAccess.size}")
        Log.d(TAG, "[getActiveTemporaryAccess] Active packages: ${activeAccess.keys}")
        
        // Return the filtered map
        return activeAccess
    }
}
