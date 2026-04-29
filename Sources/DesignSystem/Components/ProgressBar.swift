import SwiftUI

public struct ProgressBar: View {
    @Environment(\.theme) private var theme
    private let progress: Double
    private let color: Color?
    private let height: CGFloat

    public init(progress: Double, color: Color? = nil, height: CGFloat = 6) {
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.height = height
    }

    public var body: some View {
        let tint = progress >= 1 ? theme.color.danger : (color ?? theme.color.accent)
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(tint.opacity(0.18))
                Capsule().fill(tint)
                    .frame(width: geo.size.width * progress)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}
