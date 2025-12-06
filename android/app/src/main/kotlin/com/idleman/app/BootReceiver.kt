package com.idleman.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "com.htc.intent.action.QUICKBOOT_POWERON") {
            
            Log.d("IdleMan", "Boot completed received. Hydra Protocol initiating.")
            
            // In a full implementation, we might start a foreground service here
            // to ensure the app is alive. For now, we rely on the AccessibilityService
            // which the system restarts if enabled.
            
            // We can also try to launch the main activity in background if allowed (rarely allowed on modern Android)
            // or schedule a WorkManager task.
        }
    }
}
