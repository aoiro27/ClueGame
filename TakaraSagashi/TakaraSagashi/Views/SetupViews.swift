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
            Text("よるの森のぼうけん")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.lantern)
                .tracking(4)
            Text("たからさがし")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            OwlView(mood: store.hunt?.status == .cleared ? .yay : .idle, size: 200)
            Text(lead)
                .font(.system(size: 17, design: .rounded))
                .foregroundStyle(Palette.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
            Text("QRを1〜5まい用意して、家のどこかにかくします。ヒントを書いたら、こどもにタブレットをわたしてください。")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(Palette.muted)
            Button("あたらしいぼうけんをつくる") {
                if hasActive {
                    confirmNew = true
                } else {
                    store.beginSetup()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            if store.hunt != nil {
                Button("QRコードをひょうじする") { store.reviewQR() }
                    .buttonStyle(SecondaryButtonStyle())
            }
            if hasActive {
                Button("いまのぼうけんをやめる") { store.abandonHunt() }
                    .buttonStyle(SecondaryButtonStyle())
            }
            Toggle("おなじタブレットでためす（カメラなし）", isOn: Bindable(store).practiceMode)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(Palette.muted)
                .tint(Palette.lantern)
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
            Text("かくすQRコードの枚数をえらんでね。さいだい5まい。")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(Palette.muted)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 14)], spacing: 14) {
                ForEach(1...HuntEngine.maxStages, id: \.self) { count in
                    Button {
                        store.chooseStageCount(count)
                    } label: {
                        VStack {
                            Text("\(count)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                            Text("まい")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Palette.lantern)
                        .frame(maxWidth: .infinity, minHeight: 110)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color(red: 0.12, green: 0.07, blue: 0.22))
                                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Palette.lantern.opacity(0.5), lineWidth: 3))
                        )
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
                Text("このQRを保存して家のどこかにかくします。かくした場所をこども向けの言葉で書いてください。")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Palette.muted)
                if let hunt = store.hunt, let stage = store.currentStage,
                   let payload = try? HuntEngine.encodeQRPayload(hunt, stageIndex: stage.index) {
                    QRCardView(payload: payload, label: "\(stage.index)まいめ", hint: stage.hint)
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
                    Button(stage.index == hunt.stageCount ? "QRをそろえる" : "つぎのQRへ") {
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
                Text("QRを保存して印刷し、家のどこかにかくしたらスタート。")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Palette.muted)
                Toggle("おなじタブレットでためす", isOn: Bindable(store).practiceMode)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Palette.muted)
                    .tint(Palette.lantern)
                if let hunt = store.hunt {
                    ForEach(hunt.stages) { stage in
                        if let payload = try? HuntEngine.encodeQRPayload(hunt, stageIndex: stage.index) {
                            QRCardView(payload: payload, label: "\(stage.index)まいめ", hint: stage.hint)
                        }
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
