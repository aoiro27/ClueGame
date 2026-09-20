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
        ScrollView {
            VStack(spacing: 26) {
                HStack {
                    Label("よるの森", systemImage: "moon.stars.fill")
                        .font(.system(.caption, design: .rounded).weight(.bold)).tracking(2)
                    Spacer()
                    Text("ホーちゃんと ぼうけん").font(.caption)
                }.foregroundStyle(Palette.lanternHot.opacity(0.8))
                VStack(spacing: 10) {
                    Text("たからさがし")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.7).lineLimit(1)
                    Text("こんや、どんな たからに であえるかな。")
                        .font(.system(.subheadline, design: .rounded)).foregroundStyle(Palette.muted)
                }.padding(.top, 18)
                ZStack {
                    Circle().stroke(Palette.lantern.opacity(0.10), lineWidth: 1).frame(width: 250, height: 250)
                    Circle().stroke(Palette.lantern.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [2, 9])).frame(width: 218, height: 218)
                    Circle().fill(Palette.lantern.opacity(0.1)).frame(width: 190, height: 190).blur(radius: 24)
                    OwlView(mood: store.hunt?.status == .cleared ? .yay : .idle, size: 190)
                }.accessibilityHidden(true)
                VStack(spacing: 20) {
                    Text(lead).font(.system(.body, design: .rounded))
                        .foregroundStyle(Palette.muted).lineSpacing(5).multilineTextAlignment(.center)
                    if canStart {
                        Button { store.startAdventure() } label: {
                            Label(store.hunt?.status == .playing ? "ぼうけんをつづける" : "ぼうけんスタート", systemImage: "sparkles")
                        }.buttonStyle(PrimaryButtonStyle())
                    }
                }.frame(maxWidth: 360)
                MenuCard(title: "たからばこ", subtitle: store.collection.isEmpty ? "ぼうけんの思い出を、ここに。" : "集めたたから、\(store.collection.count)こ", symbol: "shippingbox.fill") {
                    store.openCollection()
                }
                HoldUnlockButton(title: "おとなのメニュー（長おし）") { store.goTo(.parent) }
                    .frame(maxWidth: .infinity).padding(.top, 4)
            }
            .padding(24).frame(maxWidth: 520).frame(maxWidth: .infinity)
        }.scrollIndicators(.hidden).foregroundStyle(.white)
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

    @State private var confirmAbandon = false

    var body: some View {
        StoryPage {
            topBar("おとなのメニュー") { store.goTo(.home) }
            GlassPanel {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionCaption(text: "ぼうけんの準備")
                        Text("いつものおうちを、\nたからの眠る森に。")
                            .font(.system(.title2, design: .rounded).bold()).foregroundStyle(.white)
                        Text("カードをかくして、ヒントを書くだけ。")
                            .font(.subheadline).foregroundStyle(Palette.muted)
                    }
                    Spacer(minLength: 0)
                    OwlView(mood: .sleep, size: 80).accessibilityHidden(true)
                }.padding(22)
            }
            VStack(spacing: 12) {
                MenuCard(title: "あたらしいぼうけん", subtitle: "枚数をえらんで、かくしものをつくる", symbol: "sparkles") {
                    if hasActive { confirmNew = true } else { store.beginSetup() }
                }
                MenuCard(title: "5まいのQRカード", subtitle: "いちど印刷すれば、何度でも遊べます", symbol: "qrcode", accent: Palette.mint) { store.openQRDeck() }
                if store.hunt != nil {
                    MenuCard(title: "ヒントをみなおす", subtitle: "今回のカードと、かくした場所を確認", symbol: "text.book.closed", accent: Color(red: 0.65, green: 0.72, blue: 1)) { store.reviewQR() }
                }
            }
            if hasActive {
                Button(role: .destructive) { confirmAbandon = true } label: {
                    Label("いまのぼうけんをやめる", systemImage: "stop.circle")
                        .font(.subheadline).foregroundStyle(Palette.coral).padding(.vertical, 12)
                }
            }
        }
        .confirmationDialog("いまのぼうけんをやめて、新しく作る？", isPresented: $confirmNew, titleVisibility: .visible) {
            Button("新しく作る", role: .destructive) { store.beginSetup() }
            Button("やめる", role: .cancel) {}
        }
        .confirmationDialog("いまのぼうけんをやめますか？", isPresented: $confirmAbandon, titleVisibility: .visible) {
            Button("ぼうけんをやめる", role: .destructive) { store.abandonHunt() }
            Button("つづける", role: .cancel) {}
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
        StoryPage {
            topBar("なんまい使う？") { store.goTo(.parent) }
            SectionCaption(text: "準備 01 / カードの枚数")
            Text("用意した5まいのうち、今回かくす枚数をえらんでね。")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(Palette.muted)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 14)], spacing: 14) {
                ForEach(1...HuntEngine.maxStages, id: \.self) { count in
                    Button {
                        store.chooseStageCount(count)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "map.fill")
                                .font(.title2)
                            Text("\(count)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                            Text("まい")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Palette.lantern)
                        .frame(maxWidth: .infinity, minHeight: 148)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Palette.lantern.opacity(0.25), lineWidth: 1))
                    }
                }
            }
            Label("はじめてなら、1〜2まいがおすすめです。", systemImage: "leaf")
                .font(.footnote).foregroundStyle(Palette.muted)
        }
    }
}

struct SetupStageView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                topBar("ヒントをつくる") { store.prevSetupStage() }
                if let hunt = store.hunt {
                    SectionCaption(text: "準備 02 / かくしもの")
                    QuestProgressView(stageCount: hunt.stageCount, currentStage: store.setupIndex)
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
                    .frame(maxWidth: .infinity)
                    .disabled(stage.hint.isEmpty)
                }
            }
            .padding(24).frame(maxWidth: 620).frame(maxWidth: .infinity)
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
                    .frame(maxWidth: .infinity).padding(.top, 12)
                Button("ホームにもどる") { store.goTo(.home) }
                    .foregroundStyle(Palette.muted)
                    .frame(maxWidth: .infinity)
            }
            .padding(24).frame(maxWidth: 620).frame(maxWidth: .infinity)
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 18)], spacing: 18) {
                ForEach(1...HuntEngine.maxStages, id: \.self) { index in
                    QRCardView(
                        payload: "\(HuntEngine.qrPrefix):\(index)",
                        label: "\(index)まいめ",
                        showsShare: true
                    )
                }
                }
            }
            .padding(24).frame(maxWidth: 620).frame(maxWidth: .infinity)
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
    VStack(alignment: .leading, spacing: 22) {
        Button(action: back) {
            Label("もどる", systemImage: "arrow.left")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 14).frame(minHeight: 44)
                .background(.white.opacity(0.06), in: Capsule())
        }.buttonStyle(.plain)
        Text(title).font(.system(.largeTitle, design: .rounded).bold())
            .foregroundStyle(.white).fixedSize(horizontal: false, vertical: true)
    }.frame(maxWidth: .infinity, alignment: .leading)
}
