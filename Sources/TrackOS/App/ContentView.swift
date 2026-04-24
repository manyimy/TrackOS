import SwiftUI

struct ContentView: View {
    @EnvironmentObject var notificationMonitor: NotificationMonitorService

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }

            ExpenseListView()
                .tabItem { Label("Expenses", systemImage: "list.bullet") }

            ReceiptScannerView()
                .tabItem { Label("Scan", systemImage: "doc.viewfinder") }

            NotificationReviewView()
                .badge(notificationMonitor.pendingExpenses.count)
                .tabItem { Label("Notifications", systemImage: "bell.badge.fill") }
        }
    }
}
