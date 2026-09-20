import SwiftUI

struct RootView: View {
    @Environment(GameStore.self) private var store

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
                case .play: PlayView()
                case .scan: ScanView()
                case .clear: ClearView()
                case .collection: CollectionView()
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.screen)
    }
}

#Preview {
    RootView()
        .environment(GameStore())
}
