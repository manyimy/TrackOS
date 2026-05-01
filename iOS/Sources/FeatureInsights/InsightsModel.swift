import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class InsightsModel {

    // MARK: - State
    public var dailySpend: [DailySpend] = []
    public var categoryBreakdown: [CategorySpend] = []
    public var smartTips: [SmartTip] = []
    public var isLoading = false
    public var error: UserFacingError?
    public var selectedPeriod: Period = .month

    // MARK: - Derived
    public var totalSpent: Decimal {
        categoryBreakdown.reduce(.zero) { $0 + $1.amount }
    }

    public var topCategory: CategorySpend? {
        categoryBreakdown.max(by: { $0.amount < $1.amount })
    }

    // MARK: - Dependencies
    private let insightEngine: any InsightEngineProtocol

    public init(insightEngine: any InsightEngineProtocol) {
        self.insightEngine = insightEngine
    }

    // MARK: - Intents
    public func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            async let trend = insightEngine.weeklyTrend(endingOn: Date())
            async let breakdown = insightEngine.categoryBreakdown(in: selectedPeriod.interval)
            async let tips = insightEngine.smartTips(for: Date())
            (dailySpend, categoryBreakdown, smartTips) = try await (trend, breakdown, tips)
        } catch {
            self.error = UserFacingError(from: error)
        }
    }
}

// MARK: - Period

public extension InsightsModel {
    enum Period: String, CaseIterable, Sendable {
        case week = "Week"
        case month = "Month"
        case year = "Year"

        var interval: DateInterval {
            let cal = Calendar.current
            let now = Date()
            switch self {
            case .week:
                let start = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: now))!
                return DateInterval(start: start, end: now)
            case .month:
                let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
                return DateInterval(start: start, end: now)
            case .year:
                let start = cal.date(from: cal.dateComponents([.year], from: now))!
                return DateInterval(start: start, end: now)
            }
        }
    }
}
