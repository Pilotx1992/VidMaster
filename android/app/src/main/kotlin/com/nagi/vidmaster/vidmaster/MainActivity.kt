package com.vidmaster.app

import android.app.Activity
import android.app.PictureInPictureParams
import android.app.RecoverableSecurityException
import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.content.IntentSender
import android.os.Build
import android.util.Rational
import android.provider.MediaStore
import com.vidmaster.app.cast.NativeCastButtonFactory
import com.vidmaster.app.cast.VidMasterCastBridge
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val PIP_CHANNEL = "vidmaster/pip"
    private val BRIGHTNESS_CHANNEL = "vidmaster/brightness"
    private val STORAGE_CHANNEL = "vidmaster/storage"
    private val YTDLP_CHANNEL = "com.vidmaster/ytdlp"
    private var castBridge: VidMasterCastBridge? = null
    private val storageChannelHandler = StorageChannelHandler(this)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        castBridge = VidMasterCastBridge(this, flutterEngine.dartExecutor.binaryMessenger).also {
            it.attach()
        }
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                NativeCastButtonFactory.VIEW_TYPE,
                NativeCastButtonFactory(this),
            )

        // Storage Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL).setMethodCallHandler { call, result ->
            if (!storageChannelHandler.handle(call, result)) {
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
                        ?: throw IllegalStateException("Unable to load ytdlp_bridge module")
                    val callAttr = module.javaClass.methods.firstOrNull {
                        it.name == "callAttr" && it.parameterTypes.size == 2
                    } ?: throw IllegalStateException("Chaquopy callAttr bridge is unavailable")
                    val response = callAttr.invoke(module, "fetch_metadata", arrayOf(url))
                    result.success(response?.toString() ?: "")
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

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        castBridge?.detach()
        castBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (storageChannelHandler.onActivityResult(requestCode, resultCode)) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}

private class StorageChannelHandler(
    private val activity: Activity,
) {
    private data class PendingRename(
        val mediaUri: android.net.Uri,
        val filePath: String,
        val newDisplayName: String,
    )

    private var pendingRename: PendingRename? = null
    private var pendingResult: MethodChannel.Result? = null

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean =
        when (call.method) {
            "getAvailableBytes" -> {
                try {
                    val path = activity.getExternalFilesDir(null) ?: activity.filesDir
                    val stat = android.os.StatFs(path.path)
                    result.success(stat.availableBytes)
                } catch (e: Exception) {
                    result.error("STORAGE_ERROR", e.message, null)
                }
                true
            }
            "renameMediaFile" -> {
                renameMediaFile(call, result)
                true
            }
            else -> false
        }

    fun onActivityResult(requestCode: Int, resultCode: Int): Boolean {
        if (requestCode != REQUEST_RENAME_MEDIA) {
            return false
        }

        val currentRename = pendingRename
        val currentResult = pendingResult
        clearPending()

        if (currentRename == null || currentResult == null) {
            return true
        }

        if (resultCode != Activity.RESULT_OK) {
            currentResult.error(
                "WRITE_ACCESS_DENIED",
                "Write access was not granted for this media file.",
                null,
            )
            return true
        }

        renameViaMediaStore(
            mediaUri = currentRename.mediaUri,
            filePath = currentRename.filePath,
            newDisplayName = currentRename.newDisplayName,
            result = currentResult,
            allowPermissionRequest = false,
        )
        return true
    }

    private fun renameMediaFile(call: MethodCall, result: MethodChannel.Result) {
        val filePath = call.argument<String>("filePath")
        val newDisplayName = call.argument<String>("newDisplayName")

        if (filePath.isNullOrBlank() || newDisplayName.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "filePath and newDisplayName are required.", null)
            return
        }

        if (pendingResult != null) {
            result.error("STORAGE_BUSY", "Another storage operation is already awaiting approval.", null)
            return
        }

        val mediaUri = resolveMediaUri(filePath)
        if (mediaUri == null) {
            result.success(mapOf("handled" to false))
            return
        }

        renameViaMediaStore(
            mediaUri = mediaUri,
            filePath = filePath,
            newDisplayName = newDisplayName,
            result = result,
            allowPermissionRequest = true,
        )
    }

    private fun renameViaMediaStore(
        mediaUri: android.net.Uri,
        filePath: String,
        newDisplayName: String,
        result: MethodChannel.Result,
        allowPermissionRequest: Boolean,
    ) {
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, newDisplayName)
            put(MediaStore.MediaColumns.TITLE, File(newDisplayName).nameWithoutExtension)
        }

        try {
            val updatedRows = activity.contentResolver.update(mediaUri, values, null, null)
            if (updatedRows <= 0) {
                result.error("RENAME_FAILED", "MediaStore did not update the file name.", null)
                return
            }

            result.success(
                mapOf(
                    "handled" to true,
                    "path" to buildTargetPath(filePath, newDisplayName),
                ),
            )
        } catch (e: RecoverableSecurityException) {
            if (!allowPermissionRequest) {
                result.error("RENAME_FAILED", e.message, null)
                return
            }
            launchPermissionRequest(
                mediaUri = mediaUri,
                filePath = filePath,
                newDisplayName = newDisplayName,
                result = result,
                intentSender = e.userAction.actionIntent.intentSender,
            )
        } catch (e: SecurityException) {
            if (!allowPermissionRequest || Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                result.error("RENAME_FAILED", e.message, null)
                return
            }
            launchPermissionRequest(
                mediaUri = mediaUri,
                filePath = filePath,
                newDisplayName = newDisplayName,
                result = result,
                intentSender = MediaStore
                    .createWriteRequest(activity.contentResolver, listOf(mediaUri))
                    .intentSender,
            )
        } catch (e: Exception) {
            result.error("RENAME_FAILED", e.message, null)
        }
    }

    private fun launchPermissionRequest(
        mediaUri: android.net.Uri,
        filePath: String,
        newDisplayName: String,
        result: MethodChannel.Result,
        intentSender: IntentSender,
    ) {
        pendingRename = PendingRename(
            mediaUri = mediaUri,
            filePath = filePath,
            newDisplayName = newDisplayName,
        )
        pendingResult = result

        try {
            activity.startIntentSenderForResult(
                intentSender,
                REQUEST_RENAME_MEDIA,
                null,
                0,
                0,
                0,
            )
        } catch (e: IntentSender.SendIntentException) {
            clearPending()
            result.error("RENAME_FAILED", e.message, null)
        }
    }

    private fun resolveMediaUri(filePath: String): android.net.Uri? {
        val displayName = File(filePath).name
        val collection = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL)
        val projection = arrayOf(
            MediaStore.Files.FileColumns._ID,
            MediaStore.Files.FileColumns.MEDIA_TYPE,
        )

        val relativePath = relativePathForMediaStore(filePath)
        val (selection, selectionArgs) =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && relativePath != null) {
                "${MediaStore.MediaColumns.RELATIVE_PATH} = ? AND ${MediaStore.MediaColumns.DISPLAY_NAME} = ?" to
                    arrayOf(relativePath, displayName)
            } else {
                "${MediaStore.MediaColumns.DATA} = ?" to arrayOf(filePath)
            }

        activity.contentResolver.query(
            collection,
            projection,
            selection,
            selectionArgs,
            null,
        )?.use { cursor ->
            if (!cursor.moveToFirst()) {
                return null
            }

            val id = cursor.getLong(0)
            val mediaType = cursor.getInt(1)
            val baseUri =
                when (mediaType) {
                    MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO ->
                        MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
                    MediaStore.Files.FileColumns.MEDIA_TYPE_AUDIO ->
                        MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
                    MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE ->
                        MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
                    else -> collection
                }
            return ContentUris.withAppendedId(baseUri, id)
        }

        return null
    }

    private fun relativePathForMediaStore(filePath: String): String? {
        val normalizedPath = filePath.replace('\\', '/')
        val prefix =
            listOf("/storage/emulated/0/", "/sdcard/").firstOrNull {
                normalizedPath.startsWith(it)
            } ?: return null

        val relativePath = normalizedPath.removePrefix(prefix)
        val lastSlash = relativePath.lastIndexOf('/')
        return if (lastSlash >= 0) relativePath.substring(0, lastSlash + 1) else ""
    }

    private fun buildTargetPath(filePath: String, newDisplayName: String): String {
        val normalizedPath = filePath.replace('\\', '/')
        val lastSlash = normalizedPath.lastIndexOf('/')
        return if (lastSlash >= 0) {
            normalizedPath.substring(0, lastSlash + 1) + newDisplayName
        } else {
            newDisplayName
        }
    }

    private fun clearPending() {
        pendingRename = null
        pendingResult = null
    }

    private companion object {
        const val REQUEST_RENAME_MEDIA = 4107
    }
}
