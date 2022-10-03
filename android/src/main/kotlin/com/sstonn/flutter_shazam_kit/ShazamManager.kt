package com.sstonn.flutter_shazam_kit

import android.Manifest
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import androidx.annotation.RequiresPermission
import com.shazam.shazamkit.*
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileInputStream

//TODO: Add more comments
class ShazamManager(private val callbackChannel: MethodChannel) {
    private lateinit var catalog: Catalog

    //use to detect via microphone
    private var streamingSession: StreamingSession? = null

    //use to detect via audio file
    private var normalSession: Session? = null
    private var signatureGenerator: SignatureGenerator? = null
    private var audioRecord: AudioRecord? = null
    private var recordingThread: Thread? = null
    private var isRecording = false
    private val coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.Main)


    fun configureShazamKitSession(
        developerToken: String?,
        flutterResult: MethodChannel.Result
    ) {
        try {
            if (developerToken == null) {
                flutterResult.success(null)
                return
            }
            val tokenProvider = DeveloperTokenProvider {
                DeveloperToken(developerToken)
            }
            catalog = ShazamKit.createShazamCatalog(tokenProvider)
            coroutineScope.launch {
                when (val result = ShazamKit.createStreamingSession(
                    catalog,
                    AudioSampleRateInHz.SAMPLE_RATE_44100,
                    8192
                )) {
                    is ShazamKitResult.Success -> {
                        streamingSession = result.data
                    }
                    is ShazamKitResult.Failure -> {
                        result.reason.message?.let { onError(it) }
                    }
                }
                when (val result = ShazamKit.createSession(catalog)) {
                    is ShazamKitResult.Success -> {
                        normalSession = result.data
                    }
                    is ShazamKitResult.Failure -> {
                        result.reason.message?.let { onError(it) }
                    }
                }

                flutterResult.success(null)
                streamingSession?.let {
                    streamingSession?.recognitionResults()?.collect { result: MatchResult ->
                        try {
                            when (result) {
                                is MatchResult.Match -> callbackChannel.invokeMethod(
                                    "matchFound",
                                    result.toJsonString()
                                )
                                is MatchResult.NoMatch -> callbackChannel.invokeMethod(
                                    "notFound",
                                    null
                                )
                                is MatchResult.Error -> callbackChannel.invokeMethod(
                                    "didHasError",
                                    result.exception.message
                                )
                            }
                        } catch (e: Exception) {
                            e.message?.let { onError(it) }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.message?.let { onError(it) }
        }
    }

    @RequiresPermission(Manifest.permission.RECORD_AUDIO)
    fun startListening() {
        try {
            if (streamingSession == null) {
                callbackChannel.invokeMethod(
                    "didHasError",
                    "ShazamSession not found, please call configureShazamKitSession() first to initialize it."
                )
                return
            }
            callbackChannel.invokeMethod("detectStateChanged", 1)
            val audioSource = MediaRecorder.AudioSource.DEFAULT
            val audioFormat = AudioFormat.Builder().setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT).setSampleRate(41_000).build()

            audioRecord =
                AudioRecord.Builder().setAudioSource(audioSource).setAudioFormat(audioFormat)
                    .build()
            val bufferSize = AudioRecord.getMinBufferSize(
                41_000,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )
            audioRecord?.startRecording()
            isRecording = true
            recordingThread = Thread({
                val readBuffer = ByteArray(bufferSize)
                while (isRecording) {
                    val actualRead = audioRecord!!.read(readBuffer, 0, bufferSize)
                    streamingSession?.matchStream(
                        readBuffer,
                        actualRead,
                        System.currentTimeMillis()
                    )
                }
            }, "AudioRecorder Thread")
            recordingThread!!.start()
        } catch (e: Exception) {
            e.message?.let { onError(it) }
        }
    }

    fun stopListening() {
        callbackChannel.invokeMethod("detectStateChanged", 0)
        if (audioRecord != null) {
            isRecording = false;
            audioRecord!!.stop()
            audioRecord!!.release()
            audioRecord = null
            recordingThread = null
        }
    }

    fun startDetectingByAudioFile(path: String) {
        callbackChannel.invokeMethod("detectStateChanged", 1)
        recordingThread = Thread({
            val fis = FileInputStream(path);
            val bufferSize = 41_000 * 20
            val buffer = ByteArray(bufferSize)
            var read = 0
//            while((fis.read(buffer)) != -1) {
//                val actualRead = fis.read(buffer,0, bufferSize)
//                read = actualRead
//
//            }
            signatureGenerator!!.append(
                fis.readBytes(),
                fis.read(fis.readBytes(),0, bufferSize),
                System.currentTimeMillis()
            )
            val signature = signatureGenerator!!.generateSignature()
            coroutineScope.launch {
                val result = normalSession!!.match(signature)
                try {
                    when (result) {
                        is MatchResult.Match -> {
                            Log.d("ABC", result.toJsonString())
                            callbackChannel.invokeMethod(
                                "matchFound",
                                result.toJsonString()
                            )
                        }
                        is MatchResult.NoMatch -> {
                            Log.d("ABC", "notFound")
                            callbackChannel.invokeMethod("notFound", null)
                        }
                        is MatchResult.Error -> {
                            Log.d("ABC", "Error")
                            result.exception.message?.let { Log.d("ABC", it) }
                            callbackChannel.invokeMethod(
                                "didHasError",
                                result.exception.message
                            )
                        }
                    }
                } catch (e: Exception) {
                    e.message?.let { onError(it) }
                }
            }
        }, "AudioRecorder Thread")
        coroutineScope.launch {
            when (val result =
                ShazamKit.createSignatureGenerator(AudioSampleRateInHz.SAMPLE_RATE_44100)) {
                is ShazamKitResult.Success -> {
                    signatureGenerator = result.data
                    recordingThread!!.start()
                }
                is ShazamKitResult.Failure -> {
                    result.reason.message?.let { onError(it) }
                }
            }
        }
    }


    fun endSession() {
        stopListening()
        streamingSession = null
    }

    private fun onError(message: String) {
        callbackChannel.invokeMethod("didHasError", message)
    }
}

fun MatchResult.Match.toJsonString(): String {
    val itemJsonArray = JSONArray()
    this.matchedMediaItems.forEach { item ->
        val itemJsonObject = JSONObject()
        itemJsonObject.put("title", item.title)
        itemJsonObject.put("subtitle", item.subtitle)
        itemJsonObject.put("shazamId", item.shazamID)
        itemJsonObject.put("appleMusicId", item.appleMusicID)
        item.appleMusicURL?.let {
            itemJsonObject.put("appleMusicUrl", it.toURI().toString())
        }
        item.artworkURL?.let {
            itemJsonObject.put("artworkUrl", it.toURI().toString())
        }
        itemJsonObject.put("artist", item.artist)
        itemJsonObject.put("matchOffset", item.matchOffsetInMs)
        item.videoURL?.let {
            itemJsonObject.put("videoUrl", it.toURI().toString())
        }
        item.webURL?.let {
            itemJsonObject.put("webUrl", it.toURI().toString())
        }
        itemJsonObject.put("genres", JSONArray(item.genres))
        itemJsonObject.put("isrc", item.isrc)
        itemJsonArray.put(itemJsonObject)
    }
    return itemJsonArray.toString()

}