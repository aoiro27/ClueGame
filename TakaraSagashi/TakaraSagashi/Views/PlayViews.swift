import SwiftUI

struct PlayView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                HoldUnlockButton(title: "おとな") { store.goTo(.parent) }
                Spacer()
                if let hunt = store.hunt {
                    HStack(spacing: 8) {
                        ForEach(1...hunt.stageCount, id: \.self) { index in
                            Text("\(index)")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundStyle(index <= hunt.currentStageIndex ? Palette.ink : Palette.muted)
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(index <= hunt.currentStageIndex ? Palette.lantern : Color(red: 0.23, green: 0.16, blue: 0.09))
                                )
                        }
                    }
                }
            }
            OwlView(mood: .talk, size: 150)
            if let hunt = store.hunt {
                Text("\(hunt.currentStageIndex)ばんめのヒント")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.lantern)
                    .tracking(3)
                Text(HuntEngine.currentHint(hunt))
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Palette.parchment)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
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
        .onChange(of: store.hunt?.currentStageIndex) { _, _ in speakHint() }
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
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Palette.lantern, lineWidth: 4)
                    .frame(width: 240, height: 240)
                    .shadow(color: Palette.lantern.opacity(0.4), radius: 12)
                Spacer()
                if showPractice, let hunt = store.hunt {
                    HStack {
                        ForEach(hunt.stages) { stage in
                            if let payload = try? HuntEngine.encodeQRPayload(hunt, stageIndex: stage.index) {
                                Button("\(stage.index)ばんをよむ") { handle(payload) }
                                    .buttonStyle(SecondaryButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
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
                    .background(Palette.night.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .padding()
                }
            }
        }
        .onDisappear { SpeechPlayer.shared.stop() }
    }

    private var showPractice: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        store.practiceMode
        #endif
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

struct ClearView: View {
    @Environment(GameStore.self) private var store
    @State private var open = false
    private var treasure: Treasure { store.awardedTreasure }

    var body: some View {
        VStack(spacing: 12) {
            ChestSceneView(hue: treasure.hue, open: open)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 32))
            OwlView(mood: .yay, size: 90)
            Text("ぼうけんクリア")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.lantern)
                .tracking(3)
            Text("たからを GET！")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
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
            .background(.white.opacity(0.12))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Palette.lantern.opacity(0.28), lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: 28))
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
                    .background(.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 28))
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
                            .background(.white.opacity(got ? 0.12 : 0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
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
