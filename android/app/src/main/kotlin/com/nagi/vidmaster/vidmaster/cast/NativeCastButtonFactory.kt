package com.vidmaster.app.cast

import android.app.Activity
import android.content.Context
import android.content.pm.ApplicationInfo
import android.graphics.Color
import android.util.Log
import android.view.ContextThemeWrapper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.mediarouter.app.MediaRouteButton
import com.google.android.gms.cast.framework.CastButtonFactory
import com.vidmaster.app.R
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeCastButtonFactory(
    private val activity: Activity,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val iconStyle = (args as? Map<*, *>)?.get("iconStyle") as? String
        return NativeCastButtonView(activity, iconStyle)
    }

    companion object {
        const val VIEW_TYPE = "vidmaster/native_cast_button"
    }
}

private class NativeCastButtonView(
    activity: Activity,
    iconStyle: String?,
) : PlatformView {
    private val container = FrameLayout(activity)
    private val buttonContext = ContextThemeWrapper(
        activity,
        if (iconStyle == "dark") {
            R.style.VidMasterNativeCastButtonDarkIconTheme
        } else {
            R.style.VidMasterNativeCastButtonLightIconTheme
        },
    )
    private val button =
        try {
            MediaRouteButton(buttonContext)
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "Unable to create native Cast button", e)
            null
        }
    private val isDebuggable =
        (activity.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

    init {
        container.setBackgroundColor(
            if (iconStyle == "dark") {
                Color.WHITE
            } else {
                Color.BLACK
            },
        )
        button?.let { castButton ->
            castButton.contentDescription = "Cast"
            keepButtonVisible()
            castButton.minimumWidth = 0
            castButton.minimumHeight = 0
            castButton.setPadding(0, 0, 0, 0)
            castButton.setOnTouchListener { _, event ->
                if (event.action == MotionEvent.ACTION_UP && isDebuggable) {
                    Log.d(TAG, "[NativeCast] chooser opened if detectable")
                }
                false
            }
            try {
                CastButtonFactory.setUpMediaRouteButton(activity, castButton)
            } catch (e: Exception) {
                castButton.isEnabled = false
                Log.w(TAG, "Unable to set up native Cast button", e)
            }

            container.addView(
                castButton,
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    Gravity.CENTER,
                ),
            )
        }
    }

    override fun getView(): View = container

    override fun dispose() = Unit

    @Suppress("DEPRECATION")
    private fun keepButtonVisible() {
        button?.setAlwaysVisible(true)
    }

    private companion object {
        const val TAG = "NativeCastButtonView"
    }
}
