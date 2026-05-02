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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
