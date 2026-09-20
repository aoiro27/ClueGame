import SwiftUI

struct QRCardView: View {
    var payload: String
    var label: String
    var hint: String?
    var showsShare = false
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
            if showsShare {
                Button {
                    shareImage = QRCodeImage.make(payload)
                } label: {
                    Label("保存して印刷", systemImage: "square.and.arrow.up")
                        .font(.system(.subheadline, design: .rounded).bold())
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 18).frame(minHeight: 48)
                        .background(Palette.ink.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                }.buttonStyle(.plain)
            }
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
    var animated = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floating = false

    private var tint: Color { Color(hue: treasure.hue / 360, saturation: 0.65, brightness: 1) }

    var body: some View {
        ZStack {
            Circle().fill(RadialGradient(colors: [tint.opacity(0.38), tint.opacity(0.03), .clear], center: .center, startRadius: 0, endRadius: size * 0.5))
            Circle().stroke(tint.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [2, 7])).padding(size * 0.07)
            Ellipse().fill(tint.opacity(0.3)).frame(width: size * 0.55, height: size * 0.07)
                .blur(radius: size * 0.035).offset(y: size * 0.35)
            TreasureSculpture(treasure: treasure)
                .frame(width: size * 0.8, height: size * 0.8)
                .shadow(color: tint.opacity(0.5), radius: size * 0.055, y: 4)
                .offset(y: floating ? -size * 0.035 : 0)
                .rotationEffect(.degrees(floating ? 3 : -2))
            ForEach(0..<treasure.rarity.starCount + 1, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: size * (index == 0 ? 0.13 : 0.07), weight: .light))
                    .foregroundStyle(index == 0 ? .white : tint)
                    .offset(x: size * (index % 2 == 0 ? -0.34 : 0.32), y: size * (-0.29 + Double(index) * 0.17))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
        .onAppear {
            if animated && !reduceMotion {
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { floating = true }
            }
        }
    }
}

/// Layered vector miniatures: real silhouettes, bevels, facets and reflective highlights.
/// The artwork scales cleanly from collection thumbnails to the reward showcase.
private struct TreasureSculpture: View {
    let treasure: Treasure

    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 100, y: size.height / 100)
            let hue = treasure.hue / 360
            let light = Color(hue: hue, saturation: 0.28, brightness: 1)
            let color = Color(hue: hue, saturation: 0.72, brightness: 0.95)
            let dark = Color(hue: hue, saturation: 0.85, brightness: 0.38)
            let gold = Color(red: 1, green: 0.78, blue: 0.33)
            func polygon(_ points: [CGPoint]) -> Path {
                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: first)
                    for point in points.dropFirst() { path.addLine(to: point) }
                    path.closeSubpath()
                }
            }
            func poly(_ coordinates: [(CGFloat, CGFloat)]) -> Path {
                polygon(coordinates.map { CGPoint(x: $0.0, y: $0.1) })
            }
            func enamel(_ path: Path) {
                context.fill(path, with: .linearGradient(Gradient(colors: [light, color, dark]), startPoint: CGPoint(x: 22, y: 15), endPoint: CGPoint(x: 78, y: 92)))
                context.stroke(path, with: .color(light.opacity(0.85)), lineWidth: 1.2)
            }
            func line(_ points: [(CGFloat, CGFloat)], color: Color, width: CGFloat = 1.5) {
                var path = Path()
                guard let first = points.first else { return }
                path.move(to: CGPoint(x: first.0, y: first.1))
                for point in points.dropFirst() { path.addLine(to: CGPoint(x: point.0, y: point.1)) }
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }
            switch treasure.shape {
            case .gem:
                enamel(poly([(30, 17), (70, 17), (88, 40), (50, 88), (12, 40)]))
                context.fill(poly([(30, 17), (50, 40), (12, 40)]), with: .color(.white.opacity(0.42)))
                context.fill(poly([(50, 40), (70, 17), (88, 40), (50, 88)]), with: .color(dark.opacity(0.5)))
                context.fill(poly([(30, 17), (70, 17), (50, 40)]), with: .color(light))
                line([(12, 40), (88, 40)], color: light)
                line([(30, 17), (50, 40), (50, 88), (70, 17)], color: light.opacity(0.6))
            case .orb:
                let sphere = Path(ellipseIn: CGRect(x: 17, y: 16, width: 66, height: 66))
                context.fill(sphere, with: .radialGradient(Gradient(colors: [.white, light, color, dark]), center: CGPoint(x: 35, y: 32), startRadius: 0, endRadius: 62))
                context.stroke(sphere, with: .color(light), lineWidth: 1)
                context.stroke(Path(ellipseIn: CGRect(x: 9, y: 40, width: 82, height: 23)), with: .color(gold.opacity(0.85)), lineWidth: 2)
                enamel(poly([(31, 82), (69, 82), (76, 88), (24, 88)]))
            case .crown:
                enamel(poly([(15, 29), (33, 45), (50, 16), (67, 45), (85, 29), (77, 77), (23, 77)]))
                context.fill(Path(roundedRect: CGRect(x: 22, y: 71, width: 56, height: 10), cornerRadius: 3), with: .color(gold))
                for x in [15.0, 50, 85] {
                    context.fill(Path(ellipseIn: CGRect(x: x - 4, y: x == 50 ? 10 : 23, width: 8, height: 8)), with: .color(gold))
                }
                context.fill(poly([(50, 43), (58, 55), (50, 67), (42, 55)]), with: .color(light))
            case .key:
                enamel(Path(ellipseIn: CGRect(x: 22, y: 12, width: 42, height: 42)))
                context.fill(Path(ellipseIn: CGRect(x: 34, y: 24, width: 18, height: 18)), with: .color(Palette.night))
                enamel(poly([(38, 51), (51, 51), (51, 70), (68, 70), (68, 80), (51, 80), (51, 89), (38, 89)]))
                line([(42, 57), (42, 82)], color: light, width: 2)
            case .medal:
                context.fill(poly([(29, 10), (47, 10), (59, 42), (40, 51)]), with: .color(color))
                context.fill(poly([(53, 10), (71, 10), (61, 51), (42, 42)]), with: .color(light))
                enamel(Path(ellipseIn: CGRect(x: 19, y: 32, width: 62, height: 62)))
                context.stroke(Path(ellipseIn: CGRect(x: 25, y: 38, width: 50, height: 50)), with: .color(gold), lineWidth: 2)
            case .map:
                enamel(poly([(12, 24), (37, 16), (63, 25), (88, 17), (88, 76), (63, 85), (37, 76), (12, 84)]))
                line([(37, 19), (37, 75)], color: dark.opacity(0.45))
                line([(63, 27), (63, 81)], color: light)
                line([(23, 64), (35, 48), (53, 57), (74, 38)], color: gold, width: 3)
                line([(68, 32), (80, 44)], color: .white, width: 3)
                line([(80, 32), (68, 44)], color: .white, width: 3)
            case .feather:
                var feather = Path()
                feather.move(to: CGPoint(x: 24, y: 81))
                feather.addCurve(to: CGPoint(x: 78, y: 10), control1: CGPoint(x: 8, y: 28), control2: CGPoint(x: 53, y: 8))
                feather.addCurve(to: CGPoint(x: 24, y: 81), control1: CGPoint(x: 92, y: 58), control2: CGPoint(x: 62, y: 88))
                enamel(feather)
                line([(19, 91), (70, 24)], color: gold, width: 3)
                for index in 0..<4 {
                    let y = CGFloat(index) * 12
                    line([(30 + y * 0.48, 75 - y), (25 + y * 0.43, 53 - y)], color: light.opacity(0.7))
                    line([(30 + y * 0.48, 75 - y), (52 + y * 0.43, 71 - y)], color: light.opacity(0.7))
                }
            case .acorn:
                enamel(Path(ellipseIn: CGRect(x: 25, y: 32, width: 50, height: 55)))
                enamel(Path(roundedRect: CGRect(x: 20, y: 27, width: 60, height: 25), cornerRadius: 12))
                line([(48, 28), (49, 18), (58, 12)], color: gold, width: 6)
                for x in stride(from: 29.0, through: 65.0, by: 12) { line([(x, 33), (x + 6, 45)], color: gold.opacity(0.75), width: 2) }
                line([(35, 57), (38, 70)], color: light, width: 3)
            case .bottle:
                enamel(poly([(39, 21), (61, 21), (61, 39), (79, 56), (79, 84), (70, 90), (30, 90), (21, 84), (21, 56), (39, 39)]))
                context.fill(Path(roundedRect: CGRect(x: 35, y: 12, width: 30, height: 15), cornerRadius: 4), with: .color(gold))
                context.fill(poly([(26, 61), (74, 61), (74, 80), (67, 85), (33, 85), (26, 80)]), with: .color(color.opacity(0.8)))
                line([(32, 52), (29, 58), (29, 74)], color: .white.opacity(0.8), width: 3)
            case .cat:
                enamel(Path(ellipseIn: CGRect(x: 25, y: 43, width: 50, height: 46)))
                enamel(poly([(23, 18), (39, 28), (61, 28), (77, 18), (76, 51), (64, 61), (36, 61), (24, 51)]))
                line([(34, 43), (39, 40), (43, 43)], color: dark, width: 2)
                line([(57, 43), (62, 40), (66, 43)], color: dark, width: 2)
                context.fill(poly([(47, 48), (53, 48), (50, 52)]), with: .color(dark))
                line([(29, 64), (71, 64)], color: gold, width: 4)
                context.fill(Path(ellipseIn: CGRect(x: 46, y: 65, width: 8, height: 8)), with: .color(gold))
            }
            // A per-treasure crest gives similar materials their own identity.
            if [.medal, .orb, .bottle, .acorn].contains(treasure.shape) {
                let crest = Image(systemName: treasure.crest)
                var resolved = context.resolve(crest)
                resolved.shading = .color(.white.opacity(0.9))
                context.draw(resolved, in: CGRect(x: 40, y: treasure.shape == .medal ? 52 : 54, width: 20, height: 20))
            }
        }
    }
}

extension Treasure {
    var accent: Color { Color(hue: hue / 360, saturation: 0.55, brightness: 1) }
    var catalogNumber: Int { (TreasureCatalog.all.firstIndex(where: { $0.id == id }) ?? 0) + 1 }
    var crest: String {
        switch id {
        case "moon-pendant", "moon-cat", "moon-feather": return "moon.fill"
        case "gold-compass", "adventure-compass": return "location.north.fill"
        case "sun-medal", "sun-crystal": return "sun.max.fill"
        case "snow-medal": return "snowflake"
        case "brave-medal": return "shield.fill"
        case "owl-medal": return "eye.fill"
        case "sea-pearl", "ocean-bottle": return "drop.fill"
        case "cloud-orb": return "cloud.fill"
        case "firefly-orb": return "sparkle"
        case "dream-bottle": return "moon.stars.fill"
        case "honey-bottle": return "hexagon.fill"
        case "rainbow-orb", "rainbow-bottle", "rainbow-seed": return "rainbow"
        case "giant-seed": return "leaf.fill"
        case "coral-pearl": return "heart.fill"
        default: return "star.fill"
        }
    }
}

extension TreasureRarity {
    var starCount: Int {
        switch self { case .common: 1; case .rare: 2; case .legendary: 3 }
    }
    var accent: Color {
        switch self { case .common: Palette.mint; case .rare: Color(red: 0.6, green: 0.7, blue: 1); case .legendary: Palette.lantern }
    }
}

struct RarityBadge: View {
    let rarity: TreasureRarity
    var body: some View {
        HStack(spacing: 5) {
            HStack(spacing: 2) {
                ForEach(0..<rarity.starCount, id: \.self) { _ in Image(systemName: "star.fill").font(.system(size: 9)) }
            }
            Text(rarity.label).font(.system(size: 12, weight: .bold, design: .rounded))
        }
        .foregroundStyle(rarity.accent)
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(rarity.accent.opacity(0.12), in: Capsule())
        .overlay(Capsule().stroke(rarity.accent.opacity(0.35), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rarity.label)
    }
}
