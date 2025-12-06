package com.idleman.app

import android.content.Context
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
// import removed

/**
 * Overlay Activity that displays Flutter-based friction tasks
 * Uses SYSTEM_ALERT_WINDOW to show overlays on top of blocked apps
 */
class OverlayActivity : FlutterActivity() {

    private val CHANNEL = "com.idleman/overlay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "close") {
                // Check if overlay was completed successfully
                val success = call.argument<Boolean>("success") ?: false
                
                if (success) {
                    // Grant temporary bypass for the blocked app
                    val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
                    val lastBlockedPackage = prefs.getString("last_blocked_package", null)
                    
                    if (lastBlockedPackage != null) {
                        AppMonitorService.instance?.grantTemporaryAccess(lastBlockedPackage)
                        android.util.Log.d("IdleMan", "Granted temporary access for: $lastBlockedPackage")
                    }
                }
                
                // Close the overlay and let user continue to the app
                finish()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Configure window to appear as overlay
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        
        // Make it full screen
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
    }

    override fun getInitialRoute(): String {
        return intent.getStringExtra("route") ?: "/overlay/bureaucrat"
    }

    override fun getDartEntrypointFunctionName(): String {
        return "overlayMain"
    }

    override fun onDestroy() {
        // Clear the overlay active flag
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        prefs.edit().putBoolean("is_overlay_active", false).apply()
        
        super.onDestroy()
        // Simply close - let Android return to previous state
        // Don't force launch home screen
    }
}