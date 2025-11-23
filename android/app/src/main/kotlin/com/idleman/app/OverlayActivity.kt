package com.idleman.app

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

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

    override fun getDartEntrypointFunctionName(): String {
        return "overlayMain"
    }

    override fun onDestroy() {
        super.onDestroy()
        // Simply close - let Android return to previous state
        // Don't force launch home screen
    }
}