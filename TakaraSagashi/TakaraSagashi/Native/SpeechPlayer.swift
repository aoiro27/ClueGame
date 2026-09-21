import AVFoundation

@MainActor
final class SpeechPlayer: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechPlayer()
    private(set) var currentOwner: UUID?
    private var synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, owner: UUID) {
        guard AudioDirector.shared.prepareForPlayback() else { return }
        synthesizer.stopSpeaking(at: .immediate)
        currentOwner = owner
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.12
        AudioDirector.shared.duck(true)
        synthesizer.speak(utterance)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            if !self.synthesizer.isSpeaking { AudioDirector.shared.duck(false) }
        }
    }

    func resetAfterForeground() {
        stop()
        synthesizer.delegate = nil
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
    }

    func stop(owner: UUID? = nil) {
        // A departing screen must never cancel the next screen’s announcement.
        if let owner, owner != currentOwner { return }
        currentOwner = nil
        synthesizer.stopSpeaking(at: .immediate)
        AudioDirector.shared.duck(false)
    }
}
