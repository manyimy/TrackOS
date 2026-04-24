import SwiftUI
import SwiftData

@main
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
