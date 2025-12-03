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
// import removed

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.idleman/native"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
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
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Set up method channel for AppMonitorService
        AppMonitorService.methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AppMonitorService.CHANNEL_NAME
        )
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

    /**
     * Update blocked apps in the accessibility service
     */
    private fun updateBlockedApps(packages: Set<String>) {
        // Save to SharedPreferences so it persists
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        prefs.edit().putStringSet("blocked_apps", packages).apply()
        
        Log.d("IdleMan", "Saved ${packages.size} blocked apps to preferences: $packages")
        
        // Update the service instance if it's running
        AppMonitorService.instance?.updateBlockedApps(packages)
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
}
