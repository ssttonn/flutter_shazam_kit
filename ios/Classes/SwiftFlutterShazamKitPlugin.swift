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
                try startListening(result: result)
            }catch{
                callbackChannel?.invokeMethod("didHasError", arguments: error.localizedDescription)
            }
        case "endDetectionWithMicrophone":
            do {
                try stopListening()
            } catch {
                callbackChannel?.invokeMethod("didHasError", arguments: "Detection end failed due to \(error)")
            }
            result(nil)
        case "pauseDetection":
            do {
                try pauseDetection()
            } catch {
                callbackChannel?.invokeMethod("didHasError", arguments: "Pause detection failed due to \(error)")
            }
        case "resumeDetection":
            do {
                try resumeDetection()
            } catch {
                callbackChannel?.invokeMethod("didHasError", arguments: "Resume detection failed due to \(error)")
            }
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
        session = SHSession()
        session?.delegate = self
    }
    
    func prepareAudio() throws{
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetoothA2DP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func generateSignature() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: .zero)

        inputNode.installTap(onBus: .zero, bufferSize: 1024, format: recordingFormat) { [weak session] buffer, _ in
            session?.matchStreamingBuffer(buffer, at: nil)
        }
    }
    
    private func startAudioRecording() throws {
      try audioEngine.start()
    }

    func startListening(result: FlutterResult) throws {
        guard session != nil else{
            callbackChannel?.invokeMethod("didHasError", arguments: "ShazamSession not found, please call configureShazamKitSession() first to initialize it.")
            result(nil)
            return
        }
        do {
            try prepareAudio()
        } catch {
            callbackChannel?.invokeMethod("didHasError", arguments: "Audio preparation failed due to \(error)")
            result(nil)
            return
        }
        generateSignature()
        do {
            try startAudioRecording()
        } catch {
            callbackChannel?.invokeMethod("didHasError", arguments: "Start audio recording failed due to \(error)")
            result(nil)
            return
        }
        
        callbackChannel?.invokeMethod("detectStateChanged", arguments: 1)
        
        result(nil)
    }
    
    func stopListening() throws {
        let audioSession = AVAudioSession.sharedInstance()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        try audioSession.setActive(false)
        callbackChannel?.invokeMethod("detectStateChanged", arguments: 0)
    }
    
    func pauseDetection() throws {
        print("Audio engine is running at pause time? \(audioEngine.isRunning)")
        audioEngine.pause()
    }
    
    func resumeDetection() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setActive(true)
        try audioEngine.start()
        print("Audio engine is running after resuming? \(audioEngine.isRunning)")
//        generateSignature()
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

