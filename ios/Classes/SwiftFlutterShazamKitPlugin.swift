import Flutter
import UIKit
import ShazamKit

@available(iOS 15.0, *)
public class SwiftFlutterShazamKitPlugin: NSObject, FlutterPlugin {
    private var session: SHSession?
    private let audioEngine = AVAudioEngine()
    private let mixerNode = AVAudioMixerNode()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_shazam_kit", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterShazamKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isShazamKitAvailable":
            result(true)
        case "startRecording":
            do{
                if (session == nil) {
                    session = SHSession()
                    session?.delegate = self
                }
                try startListening()
            }catch{
                print(error)
            }
        case "stopRecording":
            stopListening()
        default:
            print("Default case")
        }
    }
}

//MARK: ShazamKit session delegation here
//MARK: Methods for AVAudio
@available(iOS 15.0, *)
extension SwiftFlutterShazamKitPlugin{
    
    func addAudio(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
        // Add the audio to the current match request
        session?.matchStreamingBuffer(buffer, at: audioTime)
    }
    
    func startListening() throws {
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        
        // Set an output format compatible with ShazamKit.
        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)
        
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
        // Throw an error if the audio engine is already running.
        guard !audioEngine.isRunning else { return }
        let audioSession = AVAudioSession.sharedInstance()
        
        // Ask the user for permission to use the mic if required then start the engine.
        try audioSession.setCategory(.playAndRecord)
        audioSession.requestRecordPermission { [weak self] success in
            guard success, let self = self else { return }
            try? self.audioEngine.start()
        }
    }
    
    func stopListening() {
        // Check if the audio engine is already recording.
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

//MARK: Delegate methods for SHSession
@available(iOS 15.0, *)
extension SwiftFlutterShazamKitPlugin: SHSessionDelegate{
    public func session(_ session: SHSession, didFind match: SHMatch) {
        print(match.mediaItems)
        stopListening()
    }
    
    public func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print(signature)
    }
}

