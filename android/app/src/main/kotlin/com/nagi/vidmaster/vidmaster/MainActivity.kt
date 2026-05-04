package com.vidmaster.app

import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import android.os.Handler
import android.os.Looper
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private val PIP_CHANNEL = "vidmaster/pip"
    private val BRIGHTNESS_CHANNEL = "vidmaster/brightness"
    private val YTDLP_CHANNEL = "com.vidmaster/ytdlp"
    private val STORAGE_CHANNEL = "vidmaster/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Storage Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAvailableBytes") {
                try {
                    val path = getExternalFilesDir(null)
                    val stat = android.os.StatFs(path?.path)
                    val bytesAvailable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                        stat.blockCountLong * stat.blockSizeLong
                    } else {
                        stat.blockCount.toLong() * stat.blockSize.toLong()
                    }
                    result.success(bytesAvailable)
                } catch (e: Exception) {
                    result.error("STORAGE_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Initialize Chaquopy
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, YTDLP_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "fetchMetadata") {
                val url = call.arguments as String
                Thread {
                    try {
                        val python = Python.getInstance()
                        val module = python.getModule("ytdlp_bridge")
                        val jsonResult = module.callAttr("fetch_metadata", url).toString()
                        Handler(Looper.getMainLooper()).post {
                            result.success(jsonResult)
                        }
                    } catch (e: Exception) {
                        Handler(Looper.getMainLooper()).post {
                            result.error("YTDLP_ERROR", e.message, null)
                        }
                    }
                }.start()
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PIP_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "enterPip") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    try {
                        val aspectRatio = Rational(16, 9)
                        val params = PictureInPictureParams.Builder()
                            .setAspectRatio(aspectRatio)
                            .build()
                        enterPictureInPictureMode(params)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("PIP_ERROR", e.message, null)
                    }
                } else {
                    result.error("UNAVAILABLE", "PiP is not available on this device.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BRIGHTNESS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setBrightness") {
                val brightness = call.argument<Double>("value")
                if (brightness != null) {
                    val layoutParams = window.attributes
                    layoutParams.screenBrightness = brightness.toFloat()
                    window.attributes = layoutParams
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Brightness value is missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
