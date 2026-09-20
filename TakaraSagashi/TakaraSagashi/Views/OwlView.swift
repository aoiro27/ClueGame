import SwiftUI

enum OwlMood {
    case idle, talk, yay, oops, sleep
}

struct OwlView: View {
    var mood: OwlMood = .idle
    var size: CGFloat = 180

    var body: some View {
        Canvas { context, canvasSize in
            let scale = min(canvasSize.width, canvasSize.height) / 200
            context.scaleBy(x: scale, y: scale)
            let body = Path(ellipseIn: CGRect(x: 42, y: 26, width: 116, height: 148))
            context.fill(body, with: .color(Color(red: 0.42, green: 0.29, blue: 0.17)))
            context.fill(Path(ellipseIn: CGRect(x: 40, y: 76, width: 64, height: 64)), with: .color(Color(red: 1, green: 0.97, blue: 0.91)))
            context.fill(Path(ellipseIn: CGRect(x: 96, y: 76, width: 64, height: 64)), with: .color(Color(red: 1, green: 0.97, blue: 0.91)))
            let eyeScale: CGFloat = mood == .sleep ? 0.15 : 1
            context.fill(Path(ellipseIn: CGRect(x: 58, y: 96 - 14 * eyeScale, width: 28, height: 28 * eyeScale)), with: .color(Palette.ink))
            context.fill(Path(ellipseIn: CGRect(x: 114, y: 96 - 14 * eyeScale, width: 28, height: 28 * eyeScale)), with: .color(Palette.ink))
            var beak = Path()
            beak.move(to: CGPoint(x: 92, y: 124))
            beak.addLine(to: CGPoint(x: 100, y: 140))
            beak.addLine(to: CGPoint(x: 108, y: 124))
            context.fill(beak, with: .color(Color(red: 1, green: 0.69, blue: 0.29)))
            context.fill(Path(ellipseIn: CGRect(x: 41, y: 79, width: 14, height: 14)), with: .color(Palette.lantern))
            context.fill(Path(ellipseIn: CGRect(x: 145, y: 79, width: 14, height: 14)), with: .color(Palette.lantern))
        }
        .frame(width: size, height: size)
        .offset(y: mood == .yay ? -8 : 0)
        .animation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true), value: mood == .yay)
        .accessibilityLabel("ふくろうのホーちゃん")
    }
}
