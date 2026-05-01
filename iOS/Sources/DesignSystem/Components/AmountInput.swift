import SwiftUI

/// Large centred display that shows a formatted amount while the user types.
public struct AmountDisplay: View {
    @Environment(\.theme) private var theme
    private let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text.isEmpty ? "0" : text)
            .font(theme.font.display(56))
            .foregroundStyle(text.isEmpty ? theme.color.textTertiary : theme.color.text)
            .minimumScaleFactor(0.4)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
    }
}
