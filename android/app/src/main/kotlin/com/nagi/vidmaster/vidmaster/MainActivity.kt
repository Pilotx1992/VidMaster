package com.vidmaster.app

import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private val PIP_CHANNEL = "vidmaster/pip"
    private val BRIGHTNESS_CHANNEL = "vidmaster/brightness"
    private val STORAGE_CHANNEL = "vidmaster/storage"
    private val YTDLP_CHANNEL = "com.vidmaster/ytdlp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Storage Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAvailableBytes") {
                try {
                    val path = getExternalFilesDir(null)
                    val stat = android.os.StatFs(path?.path)
                    val bytesAvailable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                        stat.availableBlocksLong * stat.blockSizeLong
                    } else {
                        stat.availableBlocks.toLong() * stat.blockSize.toLong()
                    }
                    result.success(bytesAvailable)
                } catch (e: Exception) {
                    result.error("STORAGE_ERROR", e.message, null)
                }
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
            } else if (call.method == "getBrightness") {
                val brightness = window.attributes.screenBrightness
                result.success(if (brightness >= 0f) brightness.toDouble() else 0.5)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, YTDLP_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "fetchMetadata") {
                val url = call.arguments as? String
                if (url.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "URL is missing", null)
                    return@setMethodCallHandler
                }

                try {
                    val pythonClass = Class.forName("com.chaquo.python.Python")
                    val python = pythonClass.getMethod("getInstance").invoke(null)
                    val module = python.javaClass
                        .getMethod("getModule", String::class.java)
                        .invoke(python, "ytdlp_bridge")
                    val callAttr = module.javaClass.methods.first {
                        it.name == "callAttr" && it.parameterTypes.size == 2
                    }
                    val response = callAttr.invoke(module, "fetch_metadata", arrayOf(url))
                    result.success(response.toString())
                } catch (e: ClassNotFoundException) {
                    result.error("YTDLP_UNAVAILABLE", "yt-dlp is only available in experimental builds.", null)
                } catch (e: Exception) {
                    result.error("YTDLP_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
