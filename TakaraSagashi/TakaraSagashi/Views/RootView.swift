import SwiftUI

struct RootView: View {
    @Environment(GameStore.self) private var store

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("effectsEnabled") private var effectsEnabled = true

    var body: some View {
        ZStack {
            NightSky()
            Group {
                switch store.screen {
                case .home: HomeView()
                case .parent: ParentView()
                case .setupCount: SetupCountView()
                case .setupStage: SetupStageView()
                case .setupReady: SetupReadyView()
                case .qrDeck: QRDeckView()
                case .play: PlayView()
                case .scan: ScanView()
                case .clear: ClearView()
                case .collection: CollectionView()
                }
            }
        }
        .onAppear {
            AudioDirector.shared.setActive(scenePhase == .active)
            updateAudio()
        }
        .onChange(of: store.screen) { _, _ in updateAudio() }
        .onChange(of: scenePhase) { _, phase in
            AudioDirector.shared.setActive(phase == .active)
            if phase == .active {
                SpeechPlayer.shared.resetAfterForeground()
            } else {
                SpeechPlayer.shared.stop()
            }
        }
        .onChange(of: musicEnabled) { _, _ in updateAudio() }
        .onChange(of: effectsEnabled) { _, _ in updateAudio() }
        .animation(.easeInOut(duration: 0.25), value: store.screen)
    }
    private func updateAudio() {
        AudioDirector.shared.configure(music: musicEnabled, effects: effectsEnabled)
        AudioDirector.shared.music(store.screen == .clear ? "bgm_victory" :
            ([Screen.play, .scan].contains(store.screen) ? "bgm_adventure" : "bgm_forest"))
    }
}

#Preview {
    RootView()
        .environment(GameStore())
}
