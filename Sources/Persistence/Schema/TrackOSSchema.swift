import SwiftData

public enum TrackOSSchema: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)
    public static let models: [any PersistentModel.Type] = [
        Expense.self,
        Budget.self,
        Category.self,
        Account.self,
    ]
}
