import SwiftUI

struct HoldUnlockButton: View {
    var title: String
    var action: () -> Void
    @State private var progress = 0.0
    @State private var taps = 0
    @State private var holdTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.muted)
            Capsule()
                .fill(.white.opacity(0.15))
                .frame(height: 4)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Palette.lantern)
                        .frame(width: 220 * progress, height: 4)
                }
                .frame(width: 220)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 1.3, maximumDistance: 80) {
            holdTask?.cancel()
            progress = 0
            taps = 0
            action()
        } onPressingChanged: { pressing in
            holdTask?.cancel()
            if pressing {
                progress = 0
                holdTask = Task {
                    let steps = 26
                    for step in 1...steps {
                        try? await Task.sleep(for: .milliseconds(50))
                        if Task.isCancelled { return }
                        progress = Double(step) / Double(steps)
                    }
                }
            } else {
                progress = 0
            }
        }
        .onTapGesture {
            taps += 1
            if taps >= 5 {
                taps = 0
                action()
            }
        }
    }
}
