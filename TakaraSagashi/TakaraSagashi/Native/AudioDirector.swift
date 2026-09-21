import AVFoundation
import UIKit

/// Optional bundled audio lives in Audio. Missing assets are silent.
@MainActor
final class AudioDirector: NSObject {
    static let shared = AudioDirector()
    private var background: AVAudioPlayer?
    private var outgoing: AVAudioPlayer?
    private var effects: [AVAudioPlayer] = []
    private var track = ""
    private var musicEnabled = true
    private var effectsEnabled = true
    private var active = true
    private var ducked = false
    private var interrupted = false
    private let activateSession: () throws -> Void
    private var fadeTask: Task<Void, Never>?

    init(activateSession: @escaping () throws -> Void = {
        try AVAudioSession.sharedInstance().setActive(true)
    }) {
        self.activateSession = activateSession
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        NotificationCenter.default.addObserver(self, selector: #selector(interruption), name: AVAudioSession.interruptionNotification, object: nil)
    }

    func configure(music: Bool, effects: Bool) {
        musicEnabled = music
        effectsEnabled = effects
        if !effects { self.effects.forEach { $0.stop() }; self.effects.removeAll() }
        refresh()
    }

    func music(_ name: String) {
        guard track != name || background == nil else { return }
        track = name
        fadeTask?.cancel()
        outgoing?.stop()
        outgoing = background
        outgoing?.setVolume(0, fadeDuration: 0.7)
        background = player(name)
        background?.numberOfLoops = -1
        background?.volume = 0
        refresh()
        fadeTask = Task { [weak self] in
            do { try await Task.sleep(for: .milliseconds(750)) } catch { return }
            self?.outgoing?.stop()
            self?.outgoing = nil
        }
    }

    func setActive(_ value: Bool) {
        active = value
        // Foreground entry is a fresh opportunity to activate the session. iOS
        // doesn't always deliver a matching interruption-ended notification.
        if value { interrupted = false }
        if !value {
            effects.forEach { $0.stop() }
            outgoing?.stop()
        }
        refresh()
    }

    func duck(_ value: Bool) { ducked = value; refresh() }

    func play(_ name: String) {
        guard effectsEnabled, prepareForPlayback() else { return }
        effects.removeAll { !$0.isPlaying }
        if let sound = player(name) {
            sound.volume = 0.8
            effects.append(sound)
            sound.play()
        }
    }

    func successHaptic() {
        guard active else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    @discardableResult
    func prepareForPlayback() -> Bool {
        guard active, !interrupted else { return false }
        do {
            try activateSession()
            return true
        } catch {
            // Leave the state retryable on the next foreground or playback request.
            return false
        }
    }

    private func refresh() {
        let ready = prepareForPlayback()
        guard musicEnabled, ready else {
            background?.pause()
            outgoing?.stop()
            return
        }
        background?.play()
        background?.setVolume(ducked ? 0.07 : 0.3, fadeDuration: 0.5)
    }

    @objc func interruption(_ notification: Notification) {
        guard let raw = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        let wasSuspended = notification.userInfo?[AVAudioSessionInterruptionWasSuspendedKey] as? Bool ?? false
        // Suspension notifications may arrive AFTER the foreground callback.
        // They describe the previous lock, not an ongoing call or interruption.
        interrupted = type == .began && !wasSuspended
        if type == .began {
            effects.forEach { $0.stop() }
            outgoing?.stop()
        }
        // This game resumes in the foreground even when shouldResume is absent.
        // active still prevents playback while the device is locked.
        refresh()
    }

    private func player(_ name: String) -> AVAudioPlayer? {
        let extensions = [
            "bgm_forest": "mp3",
            "bgm_adventure": "wav",
            "bgm_victory": "wav",
            "sfx_qr_success": "mp3",
            "sfx_qr_retry": "mp3",
            "sfx_chest_charge": "mp3",
            "sfx_chest_open": "mp3",
            "sfx_treasure_get": "mp3"
        ]
        guard let ext = extensions[name],
              let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Audio"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.prepareToPlay()
        return player
    }
}
