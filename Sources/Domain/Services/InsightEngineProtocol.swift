import Foundation

public protocol InsightEngineProtocol: Sendable {
    func weeklyTrend(endingOn date: Date) async throws -> [DailySpend]
    func categoryBreakdown(in range: DateInterval) async throws -> [CategorySpend]
    func smartTips(for date: Date) async throws -> [SmartTip]
}
