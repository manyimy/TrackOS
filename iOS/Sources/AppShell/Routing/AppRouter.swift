import Foundation
import Observation

@Observable
@MainActor
public final class AppRouter {
    public var selectedTab: Tab = .dashboard

    public init() {}

    public func handle(_ deepLink: DeepLink) {
        switch deepLink {
        case .addExpense:
            selectedTab = .dashboard
        }
    }
}
