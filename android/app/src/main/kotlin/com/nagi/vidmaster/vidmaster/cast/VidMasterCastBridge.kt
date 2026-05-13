package com.vidmaster.app.cast

import android.content.Context
import android.content.pm.ApplicationInfo
import android.util.Log
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManager
import com.google.android.gms.cast.framework.SessionManagerListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VidMasterCastBridge(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler,
    SessionManagerListener<CastSession> {
    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, SESSION_EVENT_CHANNEL)
    private var eventSink: EventChannel.EventSink? = null
    private var sessionManager: SessionManager? = null
    private var lastError: String? = null

    fun attach() {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        initializeCast()
    }

    fun detach() {
        eventSink = null
        eventChannel.setStreamHandler(null)
        methodChannel.setMethodCallHandler(null)
        sessionManager?.removeSessionManagerListener(this, CastSession::class.java)
        sessionManager = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSessionState" -> result.success(currentSessionState())
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        initializeCast()
        emitCurrentState()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onSessionStarting(session: CastSession) {
        emitSessionState("connecting", session)
    }

    override fun onSessionStarted(session: CastSession, sessionId: String) {
        emitSessionState("connected", session)
    }

    override fun onSessionStartFailed(session: CastSession, error: Int) {
        emitSessionState("disconnected", session, error)
    }

    override fun onSessionEnding(session: CastSession) {
        emitSessionState("disconnecting", session)
    }

    override fun onSessionEnded(session: CastSession, error: Int) {
        emitSessionState("disconnected", session, error)
    }

    override fun onSessionResuming(session: CastSession, sessionId: String) {
        emitSessionState("connecting", session)
    }

    override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
        emitSessionState("connected", session)
    }

    override fun onSessionResumeFailed(session: CastSession, error: Int) {
        emitSessionState("disconnected", session, error)
    }

    override fun onSessionSuspended(session: CastSession, reason: Int) {
        emitSessionState("suspended", session, reason)
    }

    private fun initializeCast() {
        if (sessionManager != null) return

        try {
            val castContext = CastContext.getSharedInstance(context.applicationContext)
            sessionManager = castContext.sessionManager
            sessionManager?.addSessionManagerListener(this, CastSession::class.java)
            lastError = null
        } catch (e: Exception) {
            lastError = e.message ?: e.javaClass.simpleName
            Log.w(TAG, "Unable to initialize CastContext", e)
        }
    }

    private fun emitCurrentState() {
        eventSink?.success(currentSessionState())
    }

    private fun emitSessionState(
        connectionState: String,
        session: CastSession?,
        errorCode: Int? = null,
    ) {
        logSessionState(connectionState, session)
        eventSink?.success(sessionStateMap(connectionState, session, errorCode))
    }

    private fun currentSessionState(): Map<String, Any?> {
        val error = lastError
        if (error != null) {
            return mapOf(
                "platform" to "android",
                "isAvailable" to false,
                "connectionState" to "unavailable",
                "isConnected" to false,
                "error" to error,
            )
        }

        val currentSession = sessionManager?.currentCastSession
        val state = when {
            currentSession?.isConnected == true -> "connected"
            currentSession?.isConnecting == true -> "connecting"
            else -> "disconnected"
        }
        return sessionStateMap(state, currentSession)
    }

    private fun logSessionState(connectionState: String, session: CastSession?) {
        if ((context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) == 0) {
            return
        }

        val deviceName = session?.castDevice?.friendlyName ?: "-"
        Log.d(TAG, "[NativeCast] session state=$connectionState device=$deviceName")
    }

    private fun sessionStateMap(
        connectionState: String,
        session: CastSession?,
        errorCode: Int? = null,
    ): Map<String, Any?> {
        val device = session?.castDevice
        val isConnected = session?.isConnected == true

        return mapOf(
            "platform" to "android",
            "isAvailable" to true,
            "connectionState" to connectionState,
            "isConnected" to isConnected,
            "deviceId" to device?.deviceId,
            "deviceName" to device?.friendlyName,
            "sessionId" to session?.sessionId,
            "errorCode" to errorCode,
        )
    }

    private companion object {
        const val TAG = "VidMasterCastBridge"
        const val METHOD_CHANNEL = "vidmaster/native_cast"
        const val SESSION_EVENT_CHANNEL = "vidmaster/native_cast/session"
    }
}
