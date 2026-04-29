import SwiftUI

public struct ProgressRing: View {
    @Environment(\.theme) private var theme
    private let progress: Double   // 0…1
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let color: Color?

    public init(progress: Double, size: CGFloat = 56, lineWidth: CGFloat = 5, color: Color? = nil) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }

    public var body: some View {
        let tint = progress >= 1 ? theme.color.danger : (color ?? theme.color.accent)
        ZStack {
            Circle()
                .stroke(tint.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.75), value: progress)
        }
        .frame(width: size, height: size)
    }
}
