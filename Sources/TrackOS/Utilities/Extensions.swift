import Foundation

extension Date {
    var startOfMonth: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: self)
        ) ?? self
    }

    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
