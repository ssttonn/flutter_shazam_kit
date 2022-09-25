package com.sstonn.flutter_shazam_kit

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception


/** FlutterShazamKitPlugin */
class FlutterShazamKitPlugin : FlutterPlugin, MethodCallHandler,
    ActivityAware
{
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var shazamManager: ShazamManager
    private lateinit var context: Context
    private var activityBinding: ActivityPluginBinding? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_shazam_kit")
        channel.setMethodCallHandler(this)

        shazamManager = ShazamManager(
            MethodChannel(
                flutterPluginBinding.binaryMessenger,
                "flutter_shazam_kit_callback"
            )
        )
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "configureShazamKitSession" -> shazamManager.configureShazamKitSession(
                call.argument("developerToken"),
                result
            )
            "startDetectionWithMicrophone" -> {
                if (activityBinding?.activity?.applicationContext?.let {
                        ActivityCompat.checkSelfPermission(
                            it,
                            Manifest.permission.RECORD_AUDIO
                        )
                    } != PackageManager.PERMISSION_GRANTED
                ) {
                    //TODO: handle granted permission flow
                    activityBinding?.activity?.let { ActivityCompat.requestPermissions(it,arrayOf(Manifest.permission.RECORD_AUDIO),1) }
                    return
                }
                shazamManager.startListening()
                result.success(null)
            }
            "endDetectionWithMicrophone" -> {
                shazamManager.stopListening()
                result.success(null)
            }
            "endSession"->{

            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null;
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityBinding = null;
    }
}
