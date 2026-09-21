import SwiftUI

/// Deterministic particles avoid random jumps during SwiftUI redraws.
struct CelebrationParticles: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()
    var color: Color = Palette.lanternHot

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { timeline in
            Canvas { context, size in
                let elapsed = reduceMotion ? 1.5 : timeline.date.timeIntervalSince(start)
                for index in 0..<90 {
                    let seed = Double(index)
                    let progress = (elapsed * (0.15 + Double(index % 5) * 0.025) + seed * 0.037).truncatingRemainder(dividingBy: 1)
                    let x = size.width * CGFloat((seed * 0.618).truncatingRemainder(dividingBy: 1)) + sin(progress * 8 + seed) * 24
                    let y = size.height * progress
                    let radius = CGFloat(2 + index % 4)
                    var particle = context
                    particle.opacity = sin(progress * .pi) * 0.85
                    particle.translateBy(x: x, y: y)
                    particle.rotate(by: .radians(elapsed + seed))
                    let rect = CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * (index % 3 == 0 ? 4 : 2))
                    particle.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(index % 3 == 0 ? .white : color))
                }
            }
        }
        .ignoresSafeArea().allowsHitTesting(false).accessibilityHidden(true)
    }
}

struct DiscoveryView: View {
    let found: Int
    let total: Int
    let next: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            Palette.night.ignoresSafeArea()
            RadialGradient(colors: [Palette.lantern.opacity(0.32), .clear], center: .center, startRadius: 20, endRadius: 350).ignoresSafeArea()
            GloryRays(color: Palette.lantern)
            CelebrationParticles()
            ScrollView {
                VStack(spacing: 26) {
                    Text("カード はっけん！").font(.system(size: 12, weight: .bold, design: .rounded)).tracking(4).foregroundStyle(Palette.lantern)
                    ZStack {
                        ForEach(0..<3) { index in
                            Circle().stroke(Palette.lantern.opacity(0.3), lineWidth: 2)
                                .frame(width: CGFloat(150 + index * 45), height: CGFloat(150 + index * 45))
                        }
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 100)).foregroundStyle(Palette.lanternHot)
                            .shadow(color: Palette.lantern, radius: 35)
                            .scaleEffect(appeared ? 1 : 0.4)
                    }.frame(height: 260)
                    Text("みつけた！").font(.system(size: 44, weight: .heavy, design: .rounded))
                    Text("\(found)まいめのカード、だいせいかい！").font(.headline)
                    HStack(spacing: 12) {
                        ForEach(1...max(total, 1), id: \.self) { number in
                            Image(systemName: number <= found ? "star.fill" : "star")
                                .font(.title2).foregroundStyle(number <= found ? Palette.lanternHot : Palette.muted)
                        }
                    }.accessibilityLabel("\(total)まいのうち\(found)まい発見")
                    Text("あと\(max(0, total - found))まいで、たからにとどくよ").foregroundStyle(Palette.muted)
                    Button(action: next) { Label("つぎのヒントへ", systemImage: "arrow.right.circle.fill") }
                        .buttonStyle(PrimaryButtonStyle())
                }.padding(28).frame(maxWidth: 580).frame(maxWidth: .infinity)
            }
        }.foregroundStyle(.white)
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.55)) { appeared = true }
            AudioDirector.shared.play("sfx_qr_success")
            AudioDirector.shared.successHaptic()
        }
    }
}

struct GloryRays: View {
    var color: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<12) { index in
                    Ellipse()
                        .fill(LinearGradient(colors: [color.opacity(0.3), .clear], startPoint: .bottom, endPoint: .top))
                        .frame(width: 35, height: 340)
                        .offset(y: -170)
                        .rotationEffect(.degrees(Double(index) * 30))
                }
            }
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.35)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) { rotating = true }
        }
        .onChange(of: reduceMotion) { _, _ in
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { rotating = false }
        }
        .clipped().allowsHitTesting(false).accessibilityHidden(true)
    }
}
