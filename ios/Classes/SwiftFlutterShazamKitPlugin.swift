import Flutter
import UIKit
import ShazamKit

public class SwiftFlutterShazamKitPlugin: NSObject, FlutterPlugin {
    private var session: SHSession?
    private let audioEngine = AVAudioEngine()
    private let mixerNode = AVAudioMixerNode()
    private var callbackChannel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_shazam_kit", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterShazamKitPlugin(callbackChannel: FlutterMethodChannel(name: "flutter_shazam_kit_callback", binaryMessenger: registrar.messenger()))
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(callbackChannel: FlutterMethodChannel? = nil) {
        self.callbackChannel = callbackChannel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configureShazamKitSession":
            configureShazamKitSession()
            result(nil)
        case "startDetectionWithMicrophone":
            do{
                configureAudio()
                try startListening(result: result)
            }catch{
                callbackChannel?.invokeMethod("didHasError", arguments: error.localizedDescription)
            }
        case "endDetectionWithMicrophone":
            stopListening()
            result(nil)
        case "endSession":
            session = nil
            result(nil)
        default:
            result(nil)
        }
    }
}

//MARK: ShazamKit session delegation here
//MARK: Methods for AVAudio
extension SwiftFlutterShazamKitPlugin{
    func configureShazamKitSession(){
        if session == nil{
            session = SHSession()
            session?.delegate = self
        }
    }
    
    func addAudio(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
        // Add the audio to the current match request
        session?.matchStreamingBuffer(buffer, at: audioTime)
    }
    
    func configureAudio(){
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        
        // Set an output format compatible with ShazamKit.
        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        
        // Create a mixer node to convert the input.
        audioEngine.attach(mixerNode)
        
        // Attach the mixer to the microphone input and the output of the audio engine.
        audioEngine.connect(audioEngine.inputNode, to: mixerNode, format: inputFormat)
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: outputFormat)
        
        // Install a tap on the mixer node to capture the microphone audio.
        mixerNode.installTap(onBus: 0,
                             bufferSize: 8192,
                             format: outputFormat) { buffer, audioTime in
            // Add captured audio to the buffer used for making a match.
            self.addAudio(buffer: buffer, audioTime: audioTime)
        }
    }
    
    func startListening(result: FlutterResult) throws {
        guard session != nil else{
            callbackChannel?.invokeMethod("didHasError", arguments: "ShazamSession not found, please call configureShazamKitSession() first to initialize it.")
            result(nil)
            return
        }
        callbackChannel?.invokeMethod("detectStateChanged", arguments: 1)
        // Throw an error if the audio engine is already running.
        guard !audioEngine.isRunning else {
            callbackChannel?.invokeMethod("didHasError", arguments: "Audio engine is currently running, please stop the audio engine first and then try again")
            return
        }
        let audioSession = AVAudioSession.sharedInstance()
        
        // Ask the user for permission to use the mic if required then start the engine.
        try audioSession.setCategory(.playAndRecord)
        audioSession.requestRecordPermission { [weak self] success in
            guard success else {
                self?.callbackChannel?.invokeMethod("didHasError", arguments: "Recording permission not found, please allow permission first and then try again")
                return
            }
            do{
                try self?.audioEngine.start()
            }catch{
                self?.callbackChannel?.invokeMethod("didHasError", arguments: "Can't start the audio engine")
            }
        }
        result(nil)
    }
    
    func stopListening() {
        callbackChannel?.invokeMethod("detectStateChanged", arguments: 0)
        // Check if the audio engine is already recording.
        mixerNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}

//MARK: Delegate methods for SHSession
extension SwiftFlutterShazamKitPlugin: SHSessionDelegate{
    public func session(_ session: SHSession, didFind match: SHMatch) {
        var mediaItems: [[String: Any]] = []
        match.mediaItems.forEach{rawItem in
            var item: [String: Any] = [:]
            item["title"] = rawItem.title
            item["subtitle"] = rawItem.subtitle
            item["shazamId"] = rawItem.shazamID
            item["appleMusicId"] = rawItem.appleMusicID
            if let appleUrl = rawItem.appleMusicURL{
                item["appleMusicUrl"] = appleUrl.absoluteString
            }
            if let artworkUrl = rawItem.artworkURL{
                item["artworkUrl"] = artworkUrl.absoluteString
            }
            item["artist"] = rawItem.artist
            item["matchOffset"] = rawItem.matchOffset
            if let videoUrl = rawItem.videoURL{
                item["videoUrl"] = videoUrl.absoluteString
            }
            if let webUrl = rawItem.webURL{
                item["webUrl"] = webUrl.absoluteString
            }
            item["genres"] = rawItem.genres
            item["isrc"] = rawItem.isrc
            mediaItems.append(item)
        }
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: mediaItems)
            let jsonString = String(data: jsonData, encoding: .utf8)
            self.callbackChannel?.invokeMethod("matchFound", arguments: jsonString)
        }catch{
            callbackChannel?.invokeMethod("didHasError", arguments: "Error when trying to format data, please try again")
        }
    }
    
    public func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        callbackChannel?.invokeMethod("notFound", arguments: nil)
        callbackChannel?.invokeMethod("didHasError", arguments: error?.localizedDescription)
    }
}

