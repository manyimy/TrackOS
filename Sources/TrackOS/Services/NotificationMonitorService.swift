import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationMonitorService: NSObject, ObservableObject {
    @Published var pendingExpenses: [ParsedExpense] = []
    @Published var permissionGranted: Bool = false

    private let parser = NotificationParserService()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Task { await requestPermission() }
    }

    func requestPermission() async {
        do {
            permissionGranted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            permissionGranted = false
        }
    }

    // Called from PasteNotificationView or NotificationReviewView
    func parseAndQueue(text: String) {
        guard let expense = parser.parse(text: text) else { return }
        pendingExpenses.append(expense)
    }

    // Called from the app's onOpenURL to support Shortcuts automation
    // URL format: trackos://expense?text=<url-encoded notification text>
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "trackos",
              url.host == "expense",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let textParam = components.queryItems?.first(where: { $0.name == "text" }),
              let text = textParam.value
        else { return }
        parseAndQueue(text: text)
    }

    func dismiss(_ expense: ParsedExpense) {
        pendingExpenses.removeAll { $0.id == expense.id }
    }

    func dismissAll() {
        pendingExpenses.removeAll()
    }
}

extension NotificationMonitorService: UNUserNotificationCenterDelegate {
    // Receive push notifications while the app is in the foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let content = notification.request.content
        let text = "\(content.title) \(content.body)"
        Task { @MainActor in
            if let parsed = self.parser.parse(text: text) {
                self.pendingExpenses.append(parsed)
            }
        }
        completionHandler([.banner, .sound, .badge])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
