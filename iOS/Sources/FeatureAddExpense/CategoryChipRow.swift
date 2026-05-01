import SwiftUI
import Domain
import DesignSystem

public struct CategoryChipRow: View {
    @Environment(\.theme) private var theme
    private let categories: [CategoryDTO]
    @Binding private var selectedID: UUID?

    public init(categories: [CategoryDTO], selectedID: Binding<UUID?>) {
        self.categories = categories
        self._selectedID = selectedID
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.space.sm) {
                ForEach(categories) { category in
                    categoryChip(category)
                }
            }
            .padding(.horizontal, theme.space.xl)
        }
    }

    private func categoryChip(_ category: CategoryDTO) -> some View {
        let isSelected = selectedID == category.id
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                selectedID = isSelected ? nil : category.id
            }
        } label: {
            HStack(spacing: 6) {
                CategoryDot(colorHex: category.colorHex, symbolName: category.symbolName)
                    .frame(width: 20, height: 20)
                Text(category.name)
                    .font(theme.font.label(13))
                    .foregroundStyle(isSelected ? theme.color.accentInk : theme.color.text)
            }
            .padding(.horizontal, theme.space.md)
            .padding(.vertical, 8)
            .background(isSelected ? theme.color.accent : theme.color.surfaceSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.clear : theme.color.border,
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}
