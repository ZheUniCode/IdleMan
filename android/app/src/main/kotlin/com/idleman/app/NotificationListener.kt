package com.idleman.app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {
    companion object {
        var methodChannel: MethodChannel? = null
        var isDigestModeEnabled = false
        const val CHANNEL_NAME = "com.idleman.app/notifications"
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (!isDigestModeEnabled) return

        val packageName = sbn.packageName
        
        // Don't intercept our own notifications or system
        if (packageName == "com.idleman.app") return
        if (packageName == "android") return
        if (packageName == "com.android.systemui") return

        val extras = sbn.notification.extras
        val title = extras.getString("android.title")
        val text = extras.getCharSequence("android.text")?.toString()

        Log.d("IdleMan", "Intercepted notification from $packageName: $title")

        // Cancel the notification
        try {
            cancelNotification(sbn.key)
        } catch (e: Exception) {
            Log.e("IdleMan", "Failed to cancel notification: ${e.message}")
        }

        // Send to Flutter
        // We use the main thread handler to ensure we're on the right thread for MethodChannel
        // (MethodChannel must be invoked on main thread)
        // However, NotificationListenerService runs on main thread usually.
        
        methodChannel?.invokeMethod("onNotificationReceived", mapOf(
            "packageName" to packageName,
            "appName" to (title ?: "Unknown"),
            "title" to title,
            "body" to text,
            "timestamp" to sbn.postTime
        ))
    }

    override fun onListenerConnected() {
        Log.d("IdleMan", "Notification Listener Connected")
    }
}
