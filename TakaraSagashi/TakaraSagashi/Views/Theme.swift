import SwiftUI

enum Palette {
    static let night = Color(red: 0.07, green: 0.03, blue: 0.16)
    static let dusk = Color(red: 0.16, green: 0.08, blue: 0.28)
    static let lantern = Color(red: 1.0, green: 0.80, blue: 0.34)
    static let lanternHot = Color(red: 1.0, green: 0.90, blue: 0.64)
    static let parchment = Color(red: 1.0, green: 0.95, blue: 0.84)
    static let ink = Color(red: 0.10, green: 0.07, blue: 0.22)
    static let muted = Color.white.opacity(0.72)
    static let coral = Color(red: 1.0, green: 0.44, blue: 0.57)
}

struct NightSky: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.night, Palette.dusk, Color(red: 0.30, green: 0.12, blue: 0.23)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            Circle()
                .fill(Palette.lanternHot)
                .frame(width: 86, height: 86)
                .shadow(color: Palette.lantern.opacity(0.6), radius: 24)
                .offset(x: 0, y: -280)
            ForEach(0..<18, id: \.self) { index in
                Circle()
                    .fill(Palette.lanternHot)
                    .frame(width: 6, height: 6)
                    .shadow(color: Palette.lantern, radius: 6)
                    .offset(x: CGFloat(index * 18 - 150), y: CGFloat(-220 + index * 18))
                    .opacity(0.7)
            }
        }
        .allowsHitTesting(false)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var disabled = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [Palette.lanternHot, Palette.lantern], startPoint: .top, endPoint: .bottom)
            )
            .clipShape(Capsule())
            .opacity(disabled || configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white.opacity(0.14))
            .overlay(Capsule().stroke(Palette.lantern.opacity(0.4), lineWidth: 2))
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

extension TreasureRarity {
    var label: String { TreasureCatalog.rarityLabel(self) }
}
