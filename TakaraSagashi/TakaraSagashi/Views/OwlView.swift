import SwiftUI

enum OwlMood {
    case idle, talk, yay, oops, sleep
}

struct OwlView: View {
    var mood: OwlMood = .idle
    var size: CGFloat = 180
    @State private var bobbing = false

    var body: some View {
        Canvas { context, canvasSize in
            let scale = min(canvasSize.width, canvasSize.height) / 200
            context.scaleBy(x: scale, y: scale)
            let body = Path(ellipseIn: CGRect(x: 42, y: 26, width: 116, height: 148))
            context.fill(body, with: .color(Color(red: 0.42, green: 0.29, blue: 0.17)))
            // Feathered wings and a warm belly make Ho-chan read as a character, not a flat icon.
            context.fill(Path(ellipseIn: CGRect(x: 28, y: 91, width: 50, height: 72)), with: .color(Color(red: 0.33, green: 0.21, blue: 0.13)))
            context.fill(Path(ellipseIn: CGRect(x: 122, y: 91, width: 50, height: 72)), with: .color(Color(red: 0.33, green: 0.21, blue: 0.13)))
            context.fill(Path(ellipseIn: CGRect(x: 67, y: 116, width: 66, height: 48)), with: .color(Color(red: 0.92, green: 0.78, blue: 0.54)))
            context.fill(Path(ellipseIn: CGRect(x: 40, y: 76, width: 64, height: 64)), with: .color(Color(red: 1, green: 0.97, blue: 0.91)))
            context.fill(Path(ellipseIn: CGRect(x: 96, y: 76, width: 64, height: 64)), with: .color(Color(red: 1, green: 0.97, blue: 0.91)))
            let eyeScale: CGFloat = mood == .sleep ? 0.15 : 1
            context.fill(Path(ellipseIn: CGRect(x: 58, y: 96 - 14 * eyeScale, width: 28, height: 28 * eyeScale)), with: .color(Palette.ink))
            context.fill(Path(ellipseIn: CGRect(x: 114, y: 96 - 14 * eyeScale, width: 28, height: 28 * eyeScale)), with: .color(Palette.ink))
            if mood != .sleep {
                context.fill(Path(ellipseIn: CGRect(x: 64, y: 100, width: 8, height: 8)), with: .color(.white))
                context.fill(Path(ellipseIn: CGRect(x: 120, y: 100, width: 8, height: 8)), with: .color(.white))
            }
            var beak = Path()
            beak.move(to: CGPoint(x: 92, y: 124))
            beak.addLine(to: CGPoint(x: 100, y: 140))
            beak.addLine(to: CGPoint(x: 108, y: 124))
            context.fill(beak, with: .color(Color(red: 1, green: 0.69, blue: 0.29)))
            context.fill(Path(ellipseIn: CGRect(x: 41, y: 79, width: 14, height: 14)), with: .color(Palette.lantern))
            context.fill(Path(ellipseIn: CGRect(x: 145, y: 79, width: 14, height: 14)), with: .color(Palette.lantern))
        }
        .frame(width: size, height: size)
        .offset(y: bobbing ? -8 : 3)
        .rotationEffect(.degrees(mood == .yay && bobbing ? 3 : mood == .yay ? -3 : 0))
        .onAppear { withAnimation(.easeInOut(duration: mood == .yay ? 0.42 : 1.5).repeatForever(autoreverses: true)) { bobbing = true } }
        .accessibilityLabel("ふくろうのホーちゃん")
    }
}
