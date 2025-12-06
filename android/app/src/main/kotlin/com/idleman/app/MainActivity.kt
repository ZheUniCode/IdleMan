package com.idleman.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.content.Intent
import android.net.Uri
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.util.Log
import android.app.usage.UsageStatsManager
import android.app.AppOpsManager
import android.content.Context
import android.os.Process
import java.util.Calendar
import android.graphics.drawable.BitmapDrawable
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap
import android.content.ComponentName
import android.text.TextUtils

class MainActivity: FlutterActivity() {
    // Main channel for core functionality
    private val CHANNEL = "com.idleman.app/main"
    
    // Specialized channels matching NativeBridge
    private val USAGE_CHANNEL = "com.idleman.app/usage"
    private val OVERLAY_CHANNEL = "com.idleman.app/overlay"
    private val ACCESSIBILITY_CHANNEL = "com.idleman.app/accessibility"
    private val SENSORS_CHANNEL = "com.idleman.app/sensors"
    private val NOTIFICATIONS_CHANNEL = "com.idleman.app/notifications"
    
    private var methodChannel: MethodChannel? = null
    private var usageChannel: MethodChannel? = null
    private var overlayChannel: MethodChannel? = null
    private var accessibilityChannel: MethodChannel? = null
    private var sensorsChannel: MethodChannel? = null
    private var notificationsChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        setupMainChannel(flutterEngine)
        setupUsageChannel(flutterEngine)
        setupOverlayChannel(flutterEngine)
        setupAccessibilityChannel(flutterEngine)
        setupSensorsChannel(flutterEngine)
        setupNotificationsChannel(flutterEngine)
        
        // Set up method channel for AppMonitorService
        AppMonitorService.methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AppMonitorService.CHANNEL_NAME
        )

        // Set up method channel for NotificationListener
        NotificationListener.methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NotificationListener.CHANNEL_NAME
        )
    }
    
    // =========================================================================
    // MAIN CHANNEL HANDLERS
    // =========================================================================
    private fun setupMainChannel(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestIgnoreBatteryOptimization" -> {
                    requestIgnoreBatteryOptimization()
                    result.success(null)
                }
                "checkAccessibilityPermission" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibilityPermission" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "checkOverlayPermission" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "updateBlockedApps" -> {
                    val packages = call.argument<List<String>>("packages")
                    if (packages != null) {
                        updateBlockedApps(packages.toSet())
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Packages list is null", null)
                    }
                }
                "getInstalledApps" -> {
                    val apps = getInstalledApps()
                    result.success(apps)
                }
                "validateSystemTime" -> {
                    result.success(validateSystemTime())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    // =========================================================================
    // USAGE STATS CHANNEL
    // =========================================================================
    private fun setupUsageChannel(flutterEngine: FlutterEngine) {
        usageChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL)
        usageChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    requestUsageStatsPermission()
                    result.success(true)
                }
                "getUsageStats" -> {
                    val periodDays = call.argument<Int>("periodDays") ?: 1
                    val stats = getUsageStats(periodDays)
                    result.success(stats)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    // =========================================================================
    // OVERLAY CHANNEL
    // =========================================================================
    private fun setupOverlayChannel(flutterEngine: FlutterEngine) {
        overlayChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL)
        overlayChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasOverlayPermission" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "showIntentOverlay" -> {
                    // TODO: Implement overlay display
                    Log.d("IdleMan", "showIntentOverlay called")
                    result.success(true)
                }
                "showGhostTimer" -> {
                    Log.d("IdleMan", "showGhostTimer called")
                    result.success(true)
                }
                "showHardBoundary" -> {
                    Log.d("IdleMan", "showHardBoundary called")
                    result.success(true)
                }
                "dismissOverlay" -> {
                    Log.d("IdleMan", "dismissOverlay called")
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    // =========================================================================
    // ACCESSIBILITY CHANNEL
    // =========================================================================
    private fun setupAccessibilityChannel(flutterEngine: FlutterEngine) {
        accessibilityChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_CHANNEL)
        accessibilityChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled", "isServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibilityService", "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(true)
                }
                "updateBoundedApps" -> {
                    val packages = call.argument<List<String>>("packages")
                    if (packages != null) {
                        updateBlockedApps(packages.toSet())
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Packages list is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    
    // =========================================================================
    // SENSORS CHANNEL (PEDOMETER)
    // =========================================================================
    private fun setupSensorsChannel(flutterEngine: FlutterEngine) {
        sensorsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SENSORS_CHANNEL)
        sensorsChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startStepDetection" -> {
                    val targetSteps = call.argument<Int>("targetSteps") ?: 50
                    // TODO: Start step counter service
                    Log.d("IdleMan", "Starting step detection for $targetSteps steps")
                    result.success(true)
                }
                "stopStepDetection" -> {
                    // TODO: Stop step counter service
                    Log.d("IdleMan", "Stopping step detection")
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    // =========================================================================
    // NOTIFICATIONS CHANNEL
    // =========================================================================
    private fun setupNotificationsChannel(flutterEngine: FlutterEngine) {
        notificationsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATIONS_CHANNEL)
        notificationsChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasListenerAccess", "hasPermission" -> {
                    result.success(isNotificationListenerEnabled())
                }
                "requestListenerAccess", "requestPermission" -> {
                    openNotificationListenerSettings()
                    result.success(true)
                }
                "startDigestMode" -> {
                    NotificationListener.isDigestModeEnabled = true
                    Log.d("IdleMan", "Starting digest mode")
                    result.success(true)
                }
                "stopDigestMode" -> {
                    NotificationListener.isDigestModeEnabled = false
                    Log.d("IdleMan", "Stopping digest mode")
                    result.success(true)
                }
                "deliverDigest" -> {
                    Log.d("IdleMan", "Deliver digest called")
                    result.success(true)
                }
                "showForegroundNotification" -> {
                    val title = call.argument<String>("title") ?: "IdleMan Active"
                    val body = call.argument<String>("body") ?: "Monitoring boundaries"
                    Log.d("IdleMan", "Show foreground notification: $title")
                    // In a real implementation, we would update the service notification here
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    // =========================================================================
    // PERMISSION CHECKS
    // =========================================================================
    
    /**
     * Check if usage stats permission is granted
     */
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
    
    /**
     * Request usage stats permission
     */
    private fun requestUsageStatsPermission() {
        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
    }
    
    /**
     * Check if accessibility service is enabled
     */
    private fun isAccessibilityServiceEnabled(): Boolean {
        val service = "${packageName}/${AppMonitorService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        return enabledServices?.contains(service) == true
    }

    /**
     * Open accessibility settings
     */
    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }
    
    /**
     * Check if notification listener is enabled
     */
    private fun isNotificationListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (!TextUtils.isEmpty(flat)) {
            val names = flat.split(":")
            for (name in names) {
                val cn = ComponentName.unflattenFromString(name)
                if (cn != null && TextUtils.equals(packageName, cn.packageName)) {
                    return true
                }
            }
        }
        return false
    }
    
    /**
     * Open notification listener settings
     */
    private fun openNotificationListenerSettings() {
        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
    }

    /**
     * Request ignore battery optimization permission
     */
    private fun requestIgnoreBatteryOptimization() {
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
        intent.data = Uri.parse("package:$packageName")
        startActivity(intent)
    }

    /**
     * Request overlay permission
     */
    private fun requestOverlayPermission() {
        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }
    
    // =========================================================================
    // USAGE STATS
    // =========================================================================
    
    /**
     * Get usage statistics for installed apps
     */
    private fun getUsageStats(periodDays: Int): List<Map<String, Any?>> {
        if (!hasUsageStatsPermission()) {
            Log.w("IdleMan", "Usage stats permission not granted")
            return emptyList()
        }
        
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        
        val calendar = Calendar.getInstance()
        val endTime = calendar.timeInMillis
        calendar.add(Calendar.DAY_OF_YEAR, -periodDays)
        val startTime = calendar.timeInMillis
        
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        
        if (stats.isNullOrEmpty()) {
            Log.d("IdleMan", "No usage stats available")
            return emptyList()
        }
        
        val pm = packageManager
        val appStats = mutableListOf<Map<String, Any?>>()
        
        for (stat in stats) {
            if (stat.totalTimeInForeground > 0) {
                try {
                    val appInfo = pm.getApplicationInfo(stat.packageName, 0)
                    val appName = pm.getApplicationLabel(appInfo).toString()
                    
                    // Get app icon as bytes
                    var iconBytes: ByteArray? = null
                    try {
                        val drawable = pm.getApplicationIcon(stat.packageName)
                        if (drawable is BitmapDrawable) {
                            val bitmap = drawable.bitmap
                            val stream = ByteArrayOutputStream()
                            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                            iconBytes = stream.toByteArray()
                        }
                    } catch (e: Exception) {
                        Log.w("IdleMan", "Could not get icon for ${stat.packageName}")
                    }
                    
                    appStats.add(mapOf(
                        "packageName" to stat.packageName,
                        "appName" to appName,
                        "usageTimeMs" to stat.totalTimeInForeground,
                        "lastTimeUsed" to stat.lastTimeUsed,
                        "iconBytes" to iconBytes,
                        "category" to getCategoryForPackage(stat.packageName)
                    ))
                } catch (e: PackageManager.NameNotFoundException) {
                    // App not installed anymore
                }
            }
        }
        
        // Sort by usage time descending
        return appStats.sortedByDescending { it["usageTimeMs"] as Long }
    }
    
    /**
     * Get category for a package (basic heuristics)
     */
    private fun getCategoryForPackage(packageName: String): String {
        val pkg = packageName.lowercase()
        return when {
            pkg.contains("instagram") || pkg.contains("facebook") || 
            pkg.contains("twitter") || pkg.contains("tiktok") ||
            pkg.contains("snapchat") || pkg.contains("whatsapp") ||
            pkg.contains("telegram") || pkg.contains("discord") ||
            pkg.contains("reddit") -> "Social"
            
            pkg.contains("youtube") || pkg.contains("netflix") ||
            pkg.contains("spotify") || pkg.contains("twitch") ||
            pkg.contains("disney") || pkg.contains("hulu") -> "Entertainment"
            
            pkg.contains("game") || pkg.contains("supercell") ||
            pkg.contains("king.") || pkg.contains("zynga") -> "Games"
            
            pkg.contains("chrome") || pkg.contains("browser") ||
            pkg.contains("gmail") || pkg.contains("calendar") -> "Productivity"
            
            else -> "Other"
        }
    }

    /**
     * Update blocked apps in the accessibility service
     */
    private fun updateBlockedApps(packages: Set<String>) {
        // Save to SharedPreferences so it persists
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        prefs.edit().putStringSet("blocked_apps", packages).apply()
        
        Log.d("IdleMan", "Saved ${packages.size} bounded apps to preferences: $packages")
        
        // Update the service instance if it's running
        AppMonitorService.instance?.updateBoundedApps(packages)
    }

    /**
     * Get list of installed apps
     * Returns all launchable apps including system apps
     */
    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        
        Log.d("IdleMan", "Total installed apps: ${apps.size}")
        
        return apps.mapNotNull { appInfo ->
            try {
                // Get launch intent to verify the app is launchable
                val launchIntent = pm.getLaunchIntentForPackage(appInfo.packageName)
                if (launchIntent == null) {
                    return@mapNotNull null
                }
                
                val isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                
                mapOf(
                    "packageName" to appInfo.packageName,
                    "appName" to pm.getApplicationLabel(appInfo).toString(),
                    "isSystemApp" to isSystemApp
                )
            } catch (e: Exception) {
                Log.e("IdleMan", "Error getting app info for ${appInfo.packageName}: ${e.message}")
                null
            }
        }.sortedBy { it["appName"] as String }.also {
            Log.d("IdleMan", "Launchable apps found: ${it.size}")
        }
    }
    
    /**
     * Validate system time against NTP
     */
    private fun validateSystemTime(): Map<String, Any> {
        // For now, just return current time
        // In production, would compare against NTP server
        val currentTime = System.currentTimeMillis()
        return mapOf(
            "isValid" to true,
            "systemTime" to currentTime,
            "ntpTime" to currentTime,
            "offsetMs" to 0L
        )
    }
}
