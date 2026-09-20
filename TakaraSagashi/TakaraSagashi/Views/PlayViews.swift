import SwiftUI

struct PlayView: View {
    @Environment(GameStore.self) private var store
    @State private var hintAppeared = false

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                HoldUnlockButton(title: "おとな") { store.goTo(.parent) }
                Spacer()
                if let hunt = store.hunt {
                    QuestProgressView(stageCount: hunt.stageCount, currentStage: hunt.currentStageIndex)
                        .frame(maxWidth: 230)
                }
            }
            OwlView(mood: .talk, size: 142)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundStyle(Palette.lanternHot)
                        .padding(11)
                        .background(Palette.dusk, in: Circle())
                        .overlay(Circle().stroke(Palette.lantern.opacity(0.6), lineWidth: 1))
                }
            if let hunt = store.hunt {
                Text("\(hunt.currentStageIndex)ばんめのヒント")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.lantern)
                    .tracking(3)
                VStack(spacing: 12) {
                    Image(systemName: "quote.opening")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Palette.lantern.opacity(0.75))
                    Text(HuntEngine.currentHint(hunt))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                    Image(systemName: "quote.closing")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Palette.lantern.opacity(0.75))
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Palette.parchment, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Palette.lantern.opacity(0.45), lineWidth: 2))
                .shadow(color: .black.opacity(0.25), radius: 18, y: 10)
                .scaleEffect(hintAppeared ? 1 : 0.93)
                .opacity(hintAppeared ? 1 : 0)
            }
            Button("もういちどきく") {
                if let hunt = store.hunt {
                    SpeechPlayer.shared.speak(HuntEngine.currentHint(hunt))
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            Button("QRをよむ") { store.openScan() }
                .buttonStyle(PrimaryButtonStyle())
            Spacer()
        }
        .padding(24)
        .onAppear { speakHint() }
        .onAppear { withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { hintAppeared = true } }
        .onChange(of: store.hunt?.currentStageIndex) { _, _ in
            hintAppeared = false
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { hintAppeared = true }
            speakHint()
        }
        .onDisappear { SpeechPlayer.shared.stop() }
    }

    private func speakHint() {
        guard let hunt = store.hunt, hunt.status == .playing else { return }
        let hint = HuntEngine.currentHint(hunt)
        let intro = hunt.currentStageIndex == 1
            ? "さあ、ぼうけんのはじまりだよ。ヒントです。\(hint)"
            : "つぎのヒントです。\(hint)"
        SpeechPlayer.shared.speak(intro)
    }
}

struct ScanView: View {
    @Environment(GameStore.self) private var store
    @State private var cameraError: String?

    var body: some View {
        ZStack(alignment: .top) {
            QRScannerView { payload in
                handle(payload)
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button("とじる") { store.closeScan() }
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(width: 120)
                    Spacer()
                    Text("わくのなかにQRを入れてね")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding()
                Spacer()
                ScannerReticle()
                    .frame(width: 250, height: 250)
                Spacer()
                if let result = store.scanResult, result != .cleared, !isAdvanced(result) {
                    VStack(spacing: 10) {
                        OwlView(mood: .oops, size: 80)
                        Text(result.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text(result.speech)
                            .multilineTextAlignment(.center)
                        Button("もういちど") { store.clearScanResult() }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(Palette.lantern.opacity(0.55), lineWidth: 2))
                    .padding()
                }
            }
        }
        .onDisappear { SpeechPlayer.shared.stop() }
    }

    private func isAdvanced(_ result: ScanResult) -> Bool {
        if case .advanced = result { return true }
        return false
    }

    private func handle(_ payload: String) {
        if store.scanResult != nil { return }
        let result = store.scanPayload(payload)
        if let result, result != .cleared, !isAdvanced(result) {
            SpeechPlayer.shared.speak(result.speech)
        }
    }
}

private struct ScannerReticle: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.18), lineWidth: 1)
            ForEach([0.0, 90.0, 180.0, 270.0], id: \.self) { angle in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3).fill(Palette.lantern).frame(width: 52, height: 6)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3).fill(Palette.lantern).frame(width: 6, height: 52)
                        Spacer()
                    }
                    Spacer()
                }
                .rotationEffect(.degrees(angle))
            }
            Capsule().fill(Palette.lanternHot.opacity(0.75)).frame(width: 190, height: 2)
                .shadow(color: Palette.lantern, radius: 8)
        }
        .shadow(color: Palette.lantern.opacity(0.45), radius: 14)
    }
}

struct ClearView: View {
    @Environment(GameStore.self) private var store
    @State private var open = false
    private var treasure: Treasure { store.awardedTreasure }

    var body: some View {
        VStack(spacing: 12) {
            ChestSceneView(hue: treasure.hue, open: open)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(Palette.lantern.opacity(0.7), lineWidth: 2))
            OwlView(mood: .yay, size: 90)
            Text("ぼうけんクリア")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.lantern)
                .tracking(3)
            Text("たからを GET！")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            GlassPanel {
                VStack(spacing: 8) {
                TreasureArtView(treasure: treasure, size: 110)
                Text(treasure.rarity.label)
                    .foregroundStyle(Palette.lantern)
                    .tracking(2)
                Text(treasure.name)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                Text(treasure.flavor)
                    .foregroundStyle(Palette.muted)
                    .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            if let hunt = store.hunt {
                Text("QRを\(hunt.stageCount)まい、ぜんぶみつけたよ")
                    .foregroundStyle(Palette.muted)
            }
            Button("たからばこをみる") { store.finishClear() }
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding(24)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { open = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                SpeechPlayer.shared.speak("クリア！\(treasure.name)をゲットしたよ")
            }
        }
        .onDisappear { SpeechPlayer.shared.stop() }
    }
}

struct CollectionView: View {
    @Environment(GameStore.self) private var store
    @State private var selectedId: String?

    var body: some View {
        let owned = TreasureCatalog.uniqueCollected(store.collection)
        VStack(alignment: .leading, spacing: 16) {
            topBar("たからばこ") { store.goTo(.home) }
            if owned.isEmpty {
                VStack(spacing: 8) {
                    OwlView(mood: .sleep, size: 140)
                    Text("まだたからはないよ。")
                    Text("ぼうけんをクリアすると、ここにふえるよ。")
                        .foregroundStyle(Palette.muted)
                }
                .frame(maxWidth: .infinity)
            } else {
                if let selected = selectedTreasure(owned: owned) {
                    GlassPanel {
                        VStack(spacing: 8) {
                        TreasureArtView(treasure: selected, size: 120)
                        Text(selected.rarity.label)
                            .foregroundStyle(Palette.lantern)
                        Text(selected.name)
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                        Text(selected.flavor)
                            .foregroundStyle(Palette.muted)
                            .multilineTextAlignment(.center)
                        Button("なまえをきく") {
                            SpeechPlayer.shared.speak("\(selected.name)。\(selected.flavor)")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                    ForEach(TreasureCatalog.all) { treasure in
                        let got = owned.contains(treasure)
                        Button {
                            guard got else { return }
                            selectedId = treasure.id
                            SpeechPlayer.shared.speak(treasure.name)
                        } label: {
                            VStack {
                                if got {
                                    TreasureArtView(treasure: treasure, size: 54)
                                } else {
                                    Text("？")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                }
                                Text(got ? treasure.name : "？？？")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(.ultraThinMaterial.opacity(got ? 1 : 0.25), in: RoundedRectangle(cornerRadius: 18))
                            .overlay {
                                if selectedId == treasure.id {
                                    RoundedRectangle(cornerRadius: 18).stroke(Palette.lantern, lineWidth: 2)
                                }
                            }
                            .opacity(got ? 1 : 0.4)
                        }
                        .disabled(!got)
                    }
                }
                Text("\(owned.count) / \(TreasureCatalog.all.count) あつめているよ")
                    .foregroundStyle(Palette.muted)
            }
            Spacer()
        }
        .padding(24)
        .onAppear {
            selectedId = owned.first?.id
        }
    }

    private func selectedTreasure(owned: [Treasure]) -> Treasure? {
        if let selectedId, let found = owned.first(where: { $0.id == selectedId }) {
            return found
        }
        return owned.first
    }
}
