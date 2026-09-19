package dev.pulse.app

import android.app.Activity
import android.content.ContentUris
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class MainActivity : AudioServiceActivity() {
    companion object {
        private const val CHANNEL = "dev.pulse.app/device"
        private const val DELETE_REQUEST_CODE = 9911
    }

    private var pendingDeleteResult: MethodChannel.Result? = null
    private var pendingDeletePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "supportedAbis" -> result.success(Build.SUPPORTED_ABIS.toList())
                "canRequestPackageInstalls" -> {
                    result.success(
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            packageManager.canRequestPackageInstalls()
                        } else {
                            true
                        }
                    )
                }
                "openUnknownAppsSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                            Uri.parse("package:$packageName")
                        )
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                    }
                    result.success(null)
                }
                "deleteMediaFile" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.error("invalid_args", "path is required", null)
                        return@setMethodCallHandler
                    }
                    deleteMediaFile(path, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun deleteMediaFile(path: String, result: MethodChannel.Result) {
        val file = File(path)
        if (!file.exists()) {
            result.success(
                mapOf(
                    "deleted" to true,
                    "alreadyMissing" to true
                )
            )
            return
        }

        // Prefer direct delete when the process can write the path (app-owned /
        // legacy external storage). This also covers emulator Music folders on
        // older API levels.
        try {
            if (file.delete()) {
                result.success(mapOf("deleted" to true))
                return
            }
        } catch (_: SecurityException) {
            // Fall through to MediaStore.
        } catch (_: Exception) {
            // Fall through to MediaStore.
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            if (pendingDeleteResult != null) {
                result.error(
                    "delete_in_progress",
                    "Another delete confirmation is already pending",
                    null
                )
                return
            }

            val uri = findAudioContentUri(path) ?: scanAndFindAudioContentUri(path)
            if (uri == null) {
                result.success(
                    mapOf(
                        "deleted" to false,
                        "reason" to "media_store_uri_not_found"
                    )
                )
                return
            }

            try {
                val pendingIntent = MediaStore.createDeleteRequest(
                    contentResolver,
                    listOf(uri)
                )
                pendingDeleteResult = result
                pendingDeletePath = path
                startIntentSenderForResult(
                    pendingIntent.intentSender,
                    DELETE_REQUEST_CODE,
                    null,
                    0,
                    0,
                    0
                )
            } catch (e: Exception) {
                pendingDeleteResult = null
                pendingDeletePath = null
                result.error("delete_request_failed", e.message, null)
            }
            return
        }

        result.success(
            mapOf(
                "deleted" to false,
                "reason" to "permission_or_io_failure"
            )
        )
    }

    private fun findAudioContentUri(path: String): Uri? {
        val collection = audioCollection()
        val normalized = path.replace('\\', '/')
        val candidates = linkedSetOf(
            path,
            normalized,
            File(path).absolutePath,
            File(path).canonicalFile.absolutePath
        )

        for (candidate in candidates) {
            contentResolver.query(
                collection,
                arrayOf(MediaStore.Audio.Media._ID),
                "${MediaStore.Audio.Media.DATA}=?",
                arrayOf(candidate),
                null
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val id = cursor.getLong(0)
                    return ContentUris.withAppendedId(collection, id)
                }
            }
        }
        return null
    }

    private fun scanAndFindAudioContentUri(path: String): Uri? {
        val latch = CountDownLatch(1)
        var scannedUri: Uri? = null

        MediaScannerConnection.scanFile(
            this,
            arrayOf(path),
            arrayOf("audio/*")
        ) { _, uri ->
            scannedUri = uri
            latch.countDown()
        }

        try {
            latch.await(3, TimeUnit.SECONDS)
        } catch (_: InterruptedException) {
            Thread.currentThread().interrupt()
        }

        if (scannedUri != null) {
            return scannedUri
        }
        return findAudioContentUri(path)
    }

    private fun audioCollection(): Uri {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        if (requestCode == DELETE_REQUEST_CODE) {
            val result = pendingDeleteResult
            val path = pendingDeletePath
            pendingDeleteResult = null
            pendingDeletePath = null

            if (result == null) {
                super.onActivityResult(requestCode, resultCode, data)
                return
            }

            if (resultCode == Activity.RESULT_OK) {
                // Confirm removal; some OEMs report OK before FS settles.
                val stillExists = path != null && File(path).exists()
                result.success(
                    mapOf(
                        "deleted" to !stillExists,
                        "reason" to if (stillExists) "still_exists" else null
                    )
                )
            } else {
                result.success(
                    mapOf(
                        "deleted" to false,
                        "cancelled" to true
                    )
                )
            }
            return
        }

        super.onActivityResult(requestCode, resultCode, data)
    }
}
