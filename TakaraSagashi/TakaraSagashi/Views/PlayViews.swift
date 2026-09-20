import SwiftUI

struct PlayView: View {
    @Environment(GameStore.self) private var store
    @State private var hintAppeared = false

    var body: some View {
        ScrollView {
        VStack(spacing: 22) {
            VStack(spacing: 18) {
                HStack {
                    SectionCaption(text: "よるの森を たんけん中")
                    Spacer()
                    HoldUnlockButton(title: "おとな") { store.goTo(.parent) }
                }
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
            Button {
                if let hunt = store.hunt { SpeechPlayer.shared.speak(HuntEngine.currentHint(hunt)) }
            } label: { Label("もういちどきく", systemImage: "speaker.wave.2.fill") }
            .buttonStyle(SecondaryButtonStyle())
            Button { store.openScan() } label: { Label("QRをよむ", systemImage: "qrcode.viewfinder") }
                .buttonStyle(PrimaryButtonStyle())
            Spacer()
        }
        .padding(24).frame(maxWidth: 580).frame(maxWidth: .infinity)
        }.scrollIndicators(.hidden)
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
                VStack(spacing: 16) {
                    Button("とじる") { store.closeScan() }
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(width: 120)
                    Text("わくのなかにQRを入れてね")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding().frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .top, endPoint: .bottom))
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
        ScrollView {
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
                TreasureArtView(treasure: treasure, size: 164, animated: true)
                RarityBadge(rarity: treasure.rarity)
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
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.white)
        .task {
            do {
                try await Task.sleep(for: .milliseconds(450))
                open = true
                try await Task.sleep(for: .milliseconds(450))
                SpeechPlayer.shared.speak("クリア！\(treasure.name)をゲットしたよ")
            } catch { /* Leaving the screen cancels the delayed announcement. */ }
        }
        .onDisappear { SpeechPlayer.shared.stop() }
    }
}

struct CollectionView: View {
    @Environment(GameStore.self) private var store
    @State private var selectedTreasure: Treasure?
    @State private var filter = "すべて"
    private let filters = ["すべて", "みつけた", "レア", "でんせつ"]
    private var ownedIDs: Set<String> { Set(store.collection.map(\.treasureId)) }
    private var ownedCount: Int { TreasureCatalog.all.filter { ownedIDs.contains($0.id) }.count }
    private var visibleTreasures: [Treasure] {
        TreasureCatalog.all.filter { treasure in
            switch filter {
            case "みつけた": ownedIDs.contains(treasure.id)
            case "レア": treasure.rarity == .rare
            case "でんせつ": treasure.rarity == .legendary
            default: true
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                topBar("たからのずかん") { store.goTo(.home) }
                GlassPanel {
                    HStack(spacing: 18) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 36)).foregroundStyle(Palette.lantern)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("きみだけのコレクション")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text("\(ownedCount)").font(.system(size: 36, weight: .heavy, design: .rounded)).foregroundStyle(Palette.lanternHot)
                                Text("/ 50  みつけた！").foregroundStyle(Palette.muted)
                            }
                            ProgressView(value: Double(ownedCount), total: 50).tint(Palette.lantern)
                        }
                    }
                    .padding(22).frame(maxWidth: .infinity, alignment: .leading)
                }
                if ownedCount == 0 {
                    Label("ぼうけんをクリアして、さいしょのたからをみつけよう。", systemImage: "sparkles")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Palette.muted)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { item in
                            Button { filter = item } label: {
                                Text(item)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(filter == item ? Palette.ink : .white)
                                    .padding(.horizontal, 18).frame(minHeight: 44)
                                    .background(filter == item ? Palette.lanternHot : Color.white.opacity(0.09), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(filter == item ? [.isSelected] : [])
                        }
                    }
                }
                if visibleTreasures.isEmpty {
                    Text("ここには、まだたからがないよ。\nつぎのぼうけんをたのしみに！")
                        .multilineTextAlignment(.center).foregroundStyle(Palette.muted)
                        .padding(32).frame(maxWidth: .infinity)
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 14) {
                    ForEach(visibleTreasures) { treasure in
                        let got = ownedIDs.contains(treasure.id)
                        Button { selectedTreasure = treasure } label: {
                            TreasureCollectionCard(treasure: treasure, owned: got)
                        }
                        .buttonStyle(.plain)
                        .disabled(!got)
                        .accessibilityLabel(got ? "\(treasure.name)、\(treasure.rarity.label)" : "ナンバー\(treasure.catalogNumber)、まだみつけていないたから")
                        .accessibilityHint(got ? "大きくみる" : "")
                    }
                }
                Text("ぼうけんのたびに、あたらしいたからとであえるよ。")
                    .font(.footnote).foregroundStyle(Palette.muted)
                    .frame(maxWidth: .infinity).multilineTextAlignment(.center)
            }
            .padding(20).frame(maxWidth: 860)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.white)
        .sheet(item: $selectedTreasure) { treasure in
            TreasureDetailView(treasure: treasure, count: store.collection.filter { $0.treasureId == treasure.id }.count)
        }
        .onDisappear { SpeechPlayer.shared.stop() }
    }
}

private struct TreasureCollectionCard: View {
    let treasure: Treasure
    let owned: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(String(format: "No. %02d", treasure.catalogNumber))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                Spacer()
                Image(systemName: owned ? "checkmark.seal.fill" : "lock.fill")
            }
            .foregroundStyle(owned ? treasure.rarity.accent : Palette.muted.opacity(0.5))
            if owned {
                TreasureArtView(treasure: treasure, size: 112)
            } else {
                ZStack {
                    Circle().stroke(.white.opacity(0.07), style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
                        .frame(width: 84, height: 84)
                    Image(systemName: "questionmark").font(.system(size: 33, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.3))
                }.frame(height: 112)
            }
            Text(owned ? treasure.name : "ひみつのたから")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center).lineLimit(2).frame(minHeight: 36)
                .foregroundStyle(owned ? .white : Palette.muted.opacity(0.5))
            if owned {
                RarityBadge(rarity: treasure.rarity)
            } else {
                Text("まだみつけていない").font(.system(size: 10)).foregroundStyle(Palette.muted.opacity(0.5)).frame(height: 27)
            }
        }
        .padding(12).frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(colors: [owned ? treasure.accent.opacity(0.18) : .white.opacity(0.04), Palette.night.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(owned ? treasure.rarity.accent.opacity(0.45) : .white.opacity(0.09), lineWidth: 1))
    }
}

private struct TreasureDetailView: View {
    let treasure: Treasure
    let count: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            NightSky()
            ScrollView {
                VStack(spacing: 22) {
                    HStack {
                        Text(String(format: "COLLECTION  /  %02d", treasure.catalogNumber))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .tracking(2).foregroundStyle(Palette.muted)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark").font(.body.bold())
                                .frame(width: 44, height: 44)
                                .background(.white.opacity(0.1), in: Circle())
                        }.accessibilityLabel("とじる")
                    }
                    TreasureArtView(treasure: treasure, size: 250, animated: true)
                        .padding(.top, 8)
                    RarityBadge(rarity: treasure.rarity)
                    Text(treasure.name).font(.system(size: 28, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                    GlassPanel {
                        Text(treasure.flavor)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .lineSpacing(8).multilineTextAlignment(.center)
                            .padding(24).frame(maxWidth: .infinity)
                    }
                    Label("\(count)こ みつけた", systemImage: "seal.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(treasure.rarity.accent)
                    Button {
                        SpeechPlayer.shared.speak("\(treasure.name)。\(treasure.flavor)")
                    } label: { Label("たからのおはなしをきく", systemImage: "speaker.wave.2.fill") }
                        .buttonStyle(PrimaryButtonStyle())
                }
                .padding(24).frame(maxWidth: 540).frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .onDisappear { SpeechPlayer.shared.stop() }
    }
}
