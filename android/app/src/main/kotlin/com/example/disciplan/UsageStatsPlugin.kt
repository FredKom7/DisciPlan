package com.example.disciplan

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Process
import android.provider.Settings
import android.util.Base64
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.*

class UsageStatsPlugin(private val context: Context, flutterEngine: FlutterEngine) {
    private val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "usage_stats")
    private val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    private val packageManager = context.packageManager

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsagePermission" -> result.success(hasUsagePermission())
                "requestUsagePermission" -> {
                    requestUsagePermission()
                    result.success(null)
                }
                "getUsageStats" -> {
                    val startTime = call.argument<Long>("startTime") ?: 0
                    val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                    result.success(getUsageStats(startTime, endTime))
                }
                "getInstalledApps" -> result.success(getInstalledApps())
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsagePermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    private fun getUsageStats(startTime: Long, endTime: Long): List<Map<String, Any>> {
        if (!hasUsagePermission()) {
            return emptyList()
        }

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val appUsageMap = mutableMapOf<String, Long>()
        
        // Aggregate usage time by package
        stats.forEach { usageStat ->
            val packageName = usageStat.packageName
            val totalTime = usageStat.totalTimeInForeground
            appUsageMap[packageName] = (appUsageMap[packageName] ?: 0) + totalTime
        }

        // Convert to list of maps
        return appUsageMap.map { (packageName, totalTime) ->
            val appName = try {
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                packageManager.getApplicationLabel(appInfo).toString()
            } catch (e: Exception) {
                packageName
            }

            val icon = try {
                val drawable = packageManager.getApplicationIcon(packageName)
                drawableToBase64(drawable)
            } catch (e: Exception) {
                ""
            }

            mapOf<String, Any>(
                "packageName" to packageName,
                "appName" to appName,
                "usageTimeMinutes" to (totalTime / 1000 / 60).toInt(),
                "appIcon" to icon
            )
        }.filter { (it["usageTimeMinutes"] as Int) > 0 } // Only include apps with usage
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val apps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        
        return apps.filter { app ->
            // Only include launchable apps (exclude system apps without launcher)
            packageManager.getLaunchIntentForPackage(app.packageName) != null
        }.map { app ->
            val appName = packageManager.getApplicationLabel(app).toString()
            val icon = try {
                val drawable = packageManager.getApplicationIcon(app.packageName)
                drawableToBase64(drawable)
            } catch (e: Exception) {
                ""
            }

            mapOf<String, Any>(
                "packageName" to app.packageName,
                "appName" to appName,
                "appIcon" to icon
            )
        }.sortedBy { it["appName"] as String }
    }

    private fun drawableToBase64(drawable: Drawable): String {
        return try {
            val bitmap = if (drawable is BitmapDrawable) {
                drawable.bitmap
            } else {
                val bitmap = Bitmap.createBitmap(
                    drawable.intrinsicWidth,
                    drawable.intrinsicHeight,
                    Bitmap.Config.ARGB_8888
                )
                val canvas = Canvas(bitmap)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bitmap
            }

            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
        } catch (e: Exception) {
            ""
        }
    }
}
