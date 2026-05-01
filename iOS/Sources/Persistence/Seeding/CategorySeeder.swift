import Foundation

public enum CategorySeeder {
    public static let defaults: [(name: String, colorHex: String, symbolName: String)] = [
        ("Food & Dining",    "#FF9500", "fork.knife"),
        ("Transportation",   "#007AFF", "car.fill"),
        ("Shopping",         "#AF52DE", "bag.fill"),
        ("Bills & Utilities","#FF3B30", "bolt.fill"),
        ("Health",           "#34C759", "cross.fill"),
        ("Entertainment",    "#FF2D55", "tv.fill"),
        ("Housing",          "#5856D6", "house.fill"),
        ("Other",            "#A1A1AA", "ellipsis.circle.fill"),
    ]
}
