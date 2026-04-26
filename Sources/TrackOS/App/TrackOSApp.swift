#if os(iOS)
import SwiftUI
import SwiftData

// @main is intentionally omitted: this target builds as a library (framework)
// for CI. Add @main back when embedding these sources in an Xcode app target.
struct TrackOSApp: App {
    @StateObject private var notificationMonitor = NotificationMonitorService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Expense.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationMonitor)
                .onOpenURL { url in
                    notificationMonitor.handleIncomingURL(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
#endif
