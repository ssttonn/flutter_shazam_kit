package com.sstonn.flutter_shazam_kit

import android.Manifest
import android.media.*
import android.util.Log
import androidx.annotation.RequiresPermission
import com.shazam.shazamkit.*
import com.sstonn.flutter_shazam_kit.helpers.FileUtils
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.*

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
                    176400
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
                                is MatchResult.Match -> {
                                    callbackChannel.invokeMethod(
                                        "matchFound",
                                        result.toJsonString()
                                    )
                                }
                                is MatchResult.NoMatch -> {
                                    callbackChannel.invokeMethod(
                                        "notFound",
                                        null
                                    )
                                }
                                is MatchResult.Error -> {
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
        val file = File(path)
        if (!file.exists()) {
            callbackChannel.invokeMethod(
                "didHasError",
                "File not found."
            )

            return
        }
        val fileName: String = file.name.lowercase(Locale.getDefault())
        val fileNameComponents = fileName.split("\\.".toRegex()).toTypedArray()
        if (fileNameComponents.count() < 2) {
            print(fileName)
            callbackChannel.invokeMethod(
                "didHasError",
                "File name is invalid."
            )
            return
        }
        if (!FileUtils.supportedAudioExtensions().contains(fileNameComponents.last())) {
            callbackChannel.invokeMethod(
                "didHasError",
                "Not a valid audio file."
            )
            return
        }
        var extractor = MediaExtractor()
        extractor.setDataSource(file.path)
        var format: MediaFormat? = null
        val pathComponents: Array<String> = file.path.split("\\.".toRegex()).toTypedArray()
        val fileType = pathComponents.last()
        val fileSize = file.length()
        val numOfTracks = extractor.trackCount
        var i = 0
        // find and select the first audio track present in the file.
        while (i < numOfTracks) {
            format = extractor.getTrackFormat(i)
            if (format.getString(MediaFormat.KEY_MIME)!!.startsWith("audio/")) {
                extractor.selectTrack(i)
                break
            }
            i++
        }
        if (i == numOfTracks) {
            callbackChannel.invokeMethod(
                "didHasError",
                "No audio track found in selected file."
            )
            return
        }
        val numOfChannels = format!!.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        // Expected total number of samples per channel.
        val expectedNumSamples: Int =
            (format.getLong(MediaFormat.KEY_DURATION) / 1000000f * sampleRate + 0.5f).toInt()
        var codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
        codec.configure(format, null, null, 0)
        codec.start()
        var decodedSamplesSize = 0
        var mDecodedSamples: ByteBuffer
        var decodedSamples: ByteArray? = null
        var sampleSize = 0
        val inputBuffers = codec.inputBuffers
        var outputBuffers = codec.outputBuffers
        var totalSizeRead: Int = 0
        val info = MediaCodec.BufferInfo()
        var presentationTime: Long
        var doneReading = false
        // Set the size of the decoded samples buffer to 1MB (~6sec of a stereo stream at 44.1kHz).
        // For longer streams, the buffer size will be increased later on, calculating a rough
        // estimate of the total size needed to store all the samples in order to resize the buffer
        // only once.
        var audioFormat = AudioFormat.Builder().setSampleRate(sampleRate)
            .setChannelMask(if (numOfChannels == 1) AudioFormat.CHANNEL_OUT_MONO else AudioFormat.CHANNEL_OUT_STEREO)
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT).build()
        var bufferSize = AudioTrack.getMinBufferSize(
            sampleRate,
            if (numOfChannels == 1) AudioFormat.CHANNEL_OUT_MONO else AudioFormat.CHANNEL_OUT_STEREO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        // make sure minBufferSize can contain at least 1 second of audio (16 bits sample).
        if (bufferSize < numOfChannels * sampleRate * 2) {
            bufferSize = numOfChannels * sampleRate * 2
        }
        var decodedBytes = ByteBuffer.allocate(1 shl 20)
        var firstSampleData = true
        while (true) {
            // read data from file and feed it to the decoder input buffers.
            val inputBufferIndex = codec.dequeueInputBuffer(100)
            if (!doneReading && inputBufferIndex >= 0) {
                sampleSize = extractor.readSampleData(inputBuffers[inputBufferIndex], 0)
                if (firstSampleData
                    && format.getString(MediaFormat.KEY_MIME) == "audio/mp4a-latm" && sampleSize == 2
                ) {
                    extractor.advance()
                    totalSizeRead += sampleSize
                } else if (sampleSize < 0) {
                    // All samples have been read.
                    codec.queueInputBuffer(
                        inputBufferIndex, 0, 0, -1, MediaCodec.BUFFER_FLAG_END_OF_STREAM
                    )
                    doneReading = true
                } else {
                    presentationTime = extractor.sampleTime
                    codec.queueInputBuffer(inputBufferIndex, 0, sampleSize, presentationTime, 0)
                    extractor.advance()
                    totalSizeRead += sampleSize
                }
                firstSampleData = false
            }

            // Get decoded stream from the decoder output buffers.

            // Get decoded stream from the decoder output buffers.
            val outputBufferIndex = codec.dequeueOutputBuffer(info, 100)
            if (outputBufferIndex >= 0 && info.size > 0) {
                if (decodedSamplesSize < info.size) {
                    decodedSamplesSize = info.size
                    decodedSamples = ByteArray(decodedSamplesSize)
                }
                outputBuffers[outputBufferIndex][decodedSamples!!, 0, info.size]
                outputBuffers[outputBufferIndex].clear()
                // Check if buffer is big enough. Resize it if it's too small.
                if (decodedBytes.remaining() < info.size) {
                    val position: Int = decodedBytes.position()
                    var newSize: Int = (position * (1.0 * fileSize / totalSizeRead) * 1.2).toInt()
                    if (newSize - position < info.size + 5 * (1 shl 20)) {
                        newSize = position + info.size + 5 * (1 shl 20)
                    }
                    var newDecodedBytes: ByteBuffer? = null
                    var retry = 10
                    while (retry > 0) {
                        try {
                            newDecodedBytes = ByteBuffer.allocate(newSize)
                            break
                        } catch (error: OutOfMemoryError) {
                            retry--
                        }
                    }
                    if (retry == 0) {
                        break
                    }
                    decodedBytes.rewind()
                    newDecodedBytes?.put(decodedBytes)
                    if (newDecodedBytes != null) {
                        decodedBytes = newDecodedBytes
                    }
                    decodedBytes.position(position)
                }
                decodedBytes.put(decodedSamples, 0, info.size)
                codec.releaseOutputBuffer(outputBufferIndex, false)
            } else if (outputBufferIndex == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
                outputBuffers = codec.outputBuffers
            }
            if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0
                || decodedBytes.position() / (2 * numOfChannels) >= expectedNumSamples
            ) {
                break
            }
        }

        decodedBytes.rewind()
        decodedBytes.order(ByteOrder.LITTLE_ENDIAN)

        extractor.release()
        codec.stop()
        codec.release()

        val buffer = ByteArray(bufferSize)
        val audioTrack = AudioTrack.Builder().setAudioFormat(audioFormat).setBufferSizeInBytes(bufferSize).build()
        audioTrack.flush()
        audioTrack.play()
        // Setting thread feeding the audio samples to the audio hardware.
        // (Assumes mChannels = 1 or 2).
        val mPlayThread = object : Thread() {
            override fun run() {
                val position: Int = 0 * numOfChannels
                decodedBytes.position(position)
                val limit: Int = sampleRate * 70
                val destination = ByteBuffer.allocate(limit)
                while (destination.remaining() > 0) {
                    val numSamplesLeft: Int = limit - decodedBytes.position()
                    if (numSamplesLeft >= buffer.size) {
                        decodedBytes.get(buffer)
                    } else {
                        for (index in numSamplesLeft until buffer.size) {
                            buffer[index] = 0
                        }
                        decodedBytes.get(buffer, 0, numSamplesLeft)
                    }
                    destination.putTrimming(buffer)
                    audioTrack.write(buffer, 0, buffer.size)

//                    // TODO(nfaralli): use the write method that takes a ByteBuffer as argument.
//                    streamingSession?.matchStream(buffer, buffer.size, System.currentTimeMillis())
                }
                coroutineScope.launch {
                    val signatureGenerator = (ShazamKit.createSignatureGenerator(AudioSampleRateInHz.SAMPLE_RATE_44100) as ShazamKitResult.Success).data

                    signatureGenerator.append(destination.array(), bufferSize, System.currentTimeMillis())
                    val signature = signatureGenerator.generateSignature()
                    val session = (ShazamKit.createSession(catalog) as ShazamKitResult.Success).data
                    val matchResult = session.match(signature)
                    print(matchResult.toString())
                }
//                for (index in 0 until bufferSize) {
//                    buffer[index] = decodedBytes.array()[index]
//                }
//                audioTrack.flush()
//                audioTrack.play()
//                audioTrack.write(decodedBytes.array(), 0, decodedBytes.array().size )

//                val byteArray = decodedBytes.array()
//                signatureGenerator!!.append(
//                    byteArray,
//                    byteArray.size,
//                    System.currentTimeMillis()
//                )
//
//                val signature = signatureGenerator!!.generateSignature()
//
//                coroutineScope.launch {
//                    val matchResult = normalSession!!.match(signature)
//                    try {
//                        when (matchResult) {
//                            is MatchResult.Match -> {
//                                Log.d("ABC", matchResult.toJsonString())
//                                callbackChannel.invokeMethod(
//                                    "matchFound",
//                                    matchResult.toJsonString()
//                                )
//                            }
//                            is MatchResult.NoMatch -> {
//                                Log.d("ABC", "notFound")
//                                callbackChannel.invokeMethod("notFound", null)
//                            }
//                            is MatchResult.Error -> {
//                                Log.d("ABC", "Error")
//                                matchResult.exception.message?.let { Log.d("ABC", it) }
//                                callbackChannel.invokeMethod(
//                                    "didHasError",
//                                    matchResult.exception.message
//                                )
//                            }
//                        }
//                    } catch (e: Exception) {
//                        e.message?.let { onError(it) }
//                    }
//                }
            }
        }
        coroutineScope.launch {
            when (val result =
                ShazamKit.createSignatureGenerator(AudioSampleRateInHz.SAMPLE_RATE_44100)) {
                is ShazamKitResult.Success -> {
                    signatureGenerator = result.data
                    mPlayThread.start()


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

fun filePathToByteArray(path: String?): ByteArray? {
    val bufferSize = 41_000 * 10
    val fis = FileInputStream(path)
    val bos = ByteArrayOutputStream()
    val b = ByteArray(bufferSize)
    var readNum: Int
    while (fis.read(b).also { readNum = it } != -1) {
        bos.write(b, 0, readNum)
    }
    return bos.toByteArray()
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
fun ByteBuffer.putTrimming(byteArray: ByteArray) {
    if (byteArray.size <= this.capacity() - this.position()) {
        this.put(byteArray)
    } else {
        this.put(byteArray, 0, this.capacity() - this.position())
    }
}
