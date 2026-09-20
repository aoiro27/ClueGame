import SwiftUI

enum Palette {
    static let night = Color(red: 0.025, green: 0.035, blue: 0.13)
    static let dusk = Color(red: 0.12, green: 0.055, blue: 0.27)
    static let deepForest = Color(red: 0.025, green: 0.13, blue: 0.16)
    static let lantern = Color(red: 1.0, green: 0.69, blue: 0.22)
    static let lanternHot = Color(red: 1.0, green: 0.91, blue: 0.63)
    static let parchment = Color(red: 1.0, green: 0.95, blue: 0.84)
    static let ink = Color(red: 0.10, green: 0.07, blue: 0.22)
    static let muted = Color.white.opacity(0.72)
    static let coral = Color(red: 1.0, green: 0.39, blue: 0.49)
    static let mint = Color(red: 0.34, green: 0.91, blue: 0.70)
}

/// A layered storybook backdrop, drawn in code so it stays sharp on every iPad size.
struct NightSky: View {
    @State private var drifting = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [Palette.night, Palette.dusk, Palette.deepForest], startPoint: .top, endPoint: .bottom)
                Canvas { context, size in
                    for index in 0..<54 {
                        let x = CGFloat((index * 71) % 101) / 100 * size.width
                        let y = CGFloat((index * 37) % 58) / 100 * size.height
                        let radius = CGFloat(index % 3 == 0 ? 1.7 : 0.9)
                        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)), with: .color(Palette.lanternHot.opacity(index % 4 == 0 ? 0.9 : 0.45)))
                    }
                }
                .opacity(drifting ? 1 : 0.72)
                MoonView()
                    .frame(width: min(136, proxy.size.width * 0.3), height: min(136, proxy.size.width * 0.3))
                    .position(x: proxy.size.width * 0.79, y: proxy.size.height * 0.14)
                    .scaleEffect(drifting ? 1.03 : 0.97)
                ForestSilhouette().fill(Color.black.opacity(0.30)).frame(height: proxy.size.height * 0.28).frame(maxHeight: .infinity, alignment: .bottom)
                ForestSilhouette().fill(Color(red: 0.015, green: 0.08, blue: 0.11).opacity(0.9)).frame(height: proxy.size.height * 0.19).frame(maxHeight: .infinity, alignment: .bottom).offset(x: drifting ? 12 : -12)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
        .onAppear { withAnimation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) { drifting = true } }
    }
}

private struct MoonView: View {
    var body: some View {
        ZStack {
            Circle().fill(Palette.lantern.opacity(0.13)).blur(radius: 22).scaleEffect(1.35)
            Circle().fill(Palette.lanternHot)
            Circle().fill(Palette.dusk).offset(x: 27, y: -12)
        }.shadow(color: Palette.lantern.opacity(0.65), radius: 18)
    }
}

private struct ForestSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY)); path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.32))
        let peaks: [(CGFloat, CGFloat)] = [(0.06, 0.56), (0.13, 0.12), (0.20, 0.62), (0.28, 0.24), (0.36, 0.7), (0.47, 0.18), (0.57, 0.60), (0.68, 0.09), (0.77, 0.57), (0.87, 0.2), (0.96, 0.61), (1.0, 0.36)]
        for (x, y) in peaks { path.addLine(to: CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)) }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)); path.closeSubpath()
        return path
    }
}

struct GlassPanel<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(LinearGradient(colors: [.white.opacity(0.36), Palette.lantern.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2) }
            .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
    }
}

struct QuestProgressView: View {
    var stageCount: Int
    var currentStage: Int
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...stageCount, id: \.self) { index in
                HStack(spacing: 0) {
                    ZStack {
                        Circle().fill(index < currentStage ? Palette.mint : index == currentStage ? Palette.lantern : Color.white.opacity(0.14)).frame(width: 34, height: 34)
                        Image(systemName: index < currentStage ? "checkmark" : "map.fill").font(.system(size: 13, weight: .black)).foregroundStyle(index <= currentStage ? Palette.ink : Palette.muted)
                    }
                    if index < stageCount { Capsule().fill(index < currentStage ? Palette.mint : Color.white.opacity(0.15)).frame(height: 4) }
                }
            }
        }
        .padding(10).background(.black.opacity(0.18), in: Capsule())
        .accessibilityLabel("ぼうけんの進みぐあい。\(currentStage)ばんめ")
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var disabled = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundStyle(Palette.ink).frame(maxWidth: .infinity).padding(.vertical, 17)
            .background(LinearGradient(colors: [Palette.lanternHot, Palette.lantern], startPoint: .top, endPoint: .bottom), in: Capsule()).overlay(Capsule().stroke(.white.opacity(0.6), lineWidth: 1)).shadow(color: Palette.lantern.opacity(0.32), radius: 12, y: 6).opacity(disabled || configuration.isPressed ? 0.7 : 1).scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 17, weight: .bold, design: .rounded)).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(.white.opacity(configuration.isPressed ? 0.18 : 0.11), in: Capsule()).overlay(Capsule().stroke(Palette.lantern.opacity(0.45), lineWidth: 1.5)).scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

extension TreasureRarity { var label: String { TreasureCatalog.rarityLabel(self) } }
