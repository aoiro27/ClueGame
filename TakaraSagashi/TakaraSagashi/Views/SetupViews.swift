import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct HomeView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        VStack(spacing: 16) {
            Label("よるの森のぼうけん", systemImage: "sparkles")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.lantern)
                .tracking(4)
            Text("たからさがし")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            ZStack {
                Circle().fill(Palette.lantern.opacity(0.12)).frame(width: 226, height: 226).blur(radius: 14)
                OwlView(mood: store.hunt?.status == .cleared ? .yay : .idle, size: 200)
            }
            GlassPanel {
                Text(lead)
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(Palette.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
            }
            if canStart {
                Button(store.hunt?.status == .playing ? "つづける" : "ぼうけんスタート") {
                    store.startAdventure()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            Button {
                store.openCollection()
            } label: {
                HStack {
                    Image(systemName: "shippingbox.fill")
                    Text("たからばこ")
                    if !store.collection.isEmpty {
                        Text("\(store.collection.count)")
                            .padding(.horizontal, 8)
                            .background(Palette.coral)
                            .clipShape(Capsule())
                    }
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            HoldUnlockButton(title: "おとなのメニュー（長おし）") {
                store.goTo(.parent)
            }
        }
        .padding(24)
    }

    private var canStart: Bool {
        store.hunt?.status == .ready || store.hunt?.status == .playing
    }

    private var lead: String {
        switch store.hunt?.status {
        case .playing:
            "ヒントをきいて、かくされたQRをみつけよう。"
        case .cleared:
            "このぼうけんはクリア！たからばこをみてみよう。"
        case .ready:
            "ホーちゃんといっしょに、QRをたどってたからをさがそう。"
        default:
            "おとなに、かくしものづくりをおねがいしてね。"
        }
    }
}

struct ParentView: View {
    @Environment(GameStore.self) private var store
    @State private var confirmNew = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            topBar("おとなのメニュー") { store.goTo(.home) }
            OwlView(mood: .sleep, size: 96)
                .frame(maxWidth: .infinity)
            Text("QRカードは5まいまで、いちど印刷すれば何度でも使えます。ぼうけんごとに使う枚数とヒントだけ変えてください。")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(Palette.muted)
            Button("5まいのQRカードをみる") { store.openQRDeck() }
                .buttonStyle(SecondaryButtonStyle())
            Button("あたらしいぼうけんをつくる") {
                if hasActive {
                    confirmNew = true
                } else {
                    store.beginSetup()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            if store.hunt != nil {
                Button("ヒントをみなおす") { store.reviewQR() }
                    .buttonStyle(SecondaryButtonStyle())
            }
            if hasActive {
                Button("いまのぼうけんをやめる") { store.abandonHunt() }
                    .buttonStyle(SecondaryButtonStyle())
            }
            Spacer()
        }
        .padding(24)
        .confirmationDialog("いまのぼうけんをやめて、新しく作る？", isPresented: $confirmNew, titleVisibility: .visible) {
            Button("新しく作る", role: .destructive) { store.beginSetup() }
            Button("やめる", role: .cancel) {}
        }
    }

    private var hasActive: Bool {
        if let hunt = store.hunt { return hunt.status != .cleared }
        return false
    }
}

struct SetupCountView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            topBar("なんまい使う？") { store.goTo(.parent) }
            Text("用意した5まいのうち、今回かくす枚数をえらんでね。")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(Palette.muted)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 14)], spacing: 14) {
                ForEach(1...HuntEngine.maxStages, id: \.self) { count in
                    Button {
                        store.chooseStageCount(count)
                    } label: {
                        VStack {
                            Image(systemName: "map.fill")
                                .font(.title2)
                            Text("\(count)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                            Text("まい")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Palette.lantern)
                        .frame(maxWidth: .infinity, minHeight: 110)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Palette.lantern.opacity(0.5), lineWidth: 2))
                    }
                }
            }
            Spacer()
        }
        .padding(24)
    }
}

struct SetupStageView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button("まえへ") { store.prevSetupStage() }
                        .foregroundStyle(Palette.muted)
                    Spacer()
                    if let hunt = store.hunt {
                        Text("\(store.setupIndex) / \(hunt.stageCount)")
                            .foregroundStyle(Palette.lantern)
                    }
                }
                Text("かくして、ヒントをかいてね")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                if let hunt = store.hunt, let stage = store.currentStage {
                    Text("持っている \(stage.index) まいめのカードをかくして、かくした場所をこども向けの言葉で書いてください。")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(Palette.muted)
                    StageCardBadge(index: stage.index, total: hunt.stageCount)
                    Text("かくしたばしょのヒント")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    TextField("れい：リビングのソファのした", text: hintBinding, axis: .vertical)
                        .lineLimit(3...5)
                        .padding()
                        .background(Palette.parchment)
                        .foregroundStyle(Palette.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Text("\(stage.hint.count)/\(HuntEngine.maxHintLength)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Palette.muted)
                    Button(stage.index == hunt.stageCount ? "かくしものをおわる" : "つぎのカードへ") {
                        store.nextSetupStage()
                    }
                    .buttonStyle(PrimaryButtonStyle(disabled: stage.hint.isEmpty))
                    .disabled(stage.hint.isEmpty)
                }
            }
            .padding(24)
        }
    }

    private var hintBinding: Binding<String> {
        Binding(
            get: { store.currentStage?.hint ?? "" },
            set: { store.updateCurrentHint($0) }
        )
    }
}

struct SetupReadyView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                topBar("かくしものセット") { store.goTo(.parent) }
                Text("番号どおりにカードをかくしたら、こどもにタブレットをわたしてスタート。")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Palette.muted)
                if let hunt = store.hunt {
                    ForEach(hunt.stages) { stage in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(stage.index)")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(Palette.ink)
                                .frame(width: 44, height: 44)
                                .background(Palette.lantern)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(stage.index)まいめのカード")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(stage.hint)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundStyle(Palette.muted)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                Button("こどもにわたしてスタート") { store.startAdventure() }
                    .buttonStyle(PrimaryButtonStyle())
                Button("ホームにもどる") { store.goTo(.home) }
                    .foregroundStyle(Palette.muted)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
        }
    }
}

struct QRDeckView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                topBar("QRカード") { store.goTo(.parent) }
                Text("この5まいをいちど印刷して、番号がわかるようにしておいてください。ぼうけんのたびに印刷しなおす必要はありません。")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Palette.muted)
                ForEach(1...HuntEngine.maxStages, id: \.self) { index in
                    QRCardView(
                        payload: "\(HuntEngine.qrPrefix):\(index)",
                        label: "\(index)まいめ",
                        showsShare: true
                    )
                }
            }
            .padding(24)
        }
    }
}

struct StageCardBadge: View {
    var index: Int
    var total: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("\(index)")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.ink)
            Text("まいめのカードをかくす")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.ink)
            Text("ぜんぶで \(total) まい")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Palette.ink.opacity(0.7))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Palette.parchment)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Palette.lantern.opacity(0.65), lineWidth: 2))
    }
}

@ViewBuilder
func topBar(_ title: String, back: @escaping () -> Void) -> some View {
    HStack {
        Button("もどる", action: back)
            .foregroundStyle(Palette.muted)
        Spacer()
        Text(title)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }
}
