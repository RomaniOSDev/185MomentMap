import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioRecorderService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingURL: URL?
    @Published var permissionDenied = false

    private var recorder: AVAudioRecorder?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                Task { @MainActor in
                    self.permissionDenied = !granted
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func startRecording() async throws {
        guard await requestPermission() else {
            throw AudioRecorderError.permissionDenied
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("voice_\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        isRecording = true
        recordingURL = url
    }

    func stopRecording() -> Data? {
        recorder?.stop()
        isRecording = false
        defer { recorder = nil }

        guard let url = recordingURL,
              let data = try? Data(contentsOf: url) else { return nil }
        return data
    }
}

enum AudioRecorderError: Error {
    case permissionDenied
}

@MainActor
final class AudioPlayerService: ObservableObject {
    private var player: AVAudioPlayer?

    func play(data: Data) throws {
        player = try AVAudioPlayer(data: data)
        player?.play()
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
