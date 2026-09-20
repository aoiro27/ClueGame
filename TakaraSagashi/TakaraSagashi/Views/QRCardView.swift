import SwiftUI

struct QRCardView: View {
    var payload: String
    var label: String
    var hint: String?
    @State private var shareImage: UIImage?

    var body: some View {
        VStack(spacing: 10) {
            Text(label)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.ink)
            if let image = QRCodeImage.make(payload) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.92, green: 0.84, blue: 0.68))
                    .frame(width: 180, height: 180)
            }
            if let hint, !hint.isEmpty {
                Text("かくしばしょ：\(hint)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.ink)
            }
            Button("保存して印刷") {
                shareImage = QRCodeImage.make(payload)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Palette.parchment)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
        .sheet(isPresented: Binding(
            get: { shareImage != nil },
            set: { if !$0 { shareImage = nil } }
        )) {
            if let shareImage {
                ActivityView(items: [shareImage])
            }
        }
    }
}

struct TreasureArtView: View {
    var treasure: Treasure
    var size: CGFloat = 120

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(hue: treasure.hue / 360, saturation: 0.55, brightness: 0.95),
                        Color(hue: treasure.hue / 360, saturation: 0.75, brightness: 0.55),
                    ],
                    center: .topLeading,
                    startRadius: 4,
                    endRadius: size
                )
            )
            .overlay {
                Text(symbol)
                    .font(.system(size: size * 0.42))
            }
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            .accessibilityHidden(true)
    }

    private var symbol: String {
        switch treasure.shape {
        case .gem: "◆"
        case .orb: "●"
        case .crown: "♛"
        case .key: "🔑"
        case .medal: "✪"
        case .map: "🗺️"
        case .feather: "🪶"
        case .acorn: "🌰"
        case .bottle: "🧪"
        case .cat: "🐱"
        }
    }
}
