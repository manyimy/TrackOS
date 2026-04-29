import SwiftUI
import Domain

// MARK: - Service Environment Keys

private struct ExpenseServiceKey: EnvironmentKey {
    static let defaultValue: any ExpenseServiceProtocol = NoOpExpenseService()
}

private struct BudgetServiceKey: EnvironmentKey {
    static let defaultValue: any BudgetServiceProtocol = NoOpBudgetService()
}

private struct InsightEngineKey: EnvironmentKey {
    static let defaultValue: any InsightEngineProtocol = NoOpInsightEngine()
}

private struct FXServiceKey: EnvironmentKey {
    static let defaultValue: any FXServiceProtocol = NoOpFXService()
}

private struct CategoryServiceKey: EnvironmentKey {
    static let defaultValue: any CategoryServiceProtocol = NoOpCategoryService()
}

private struct ClassifierKey: EnvironmentKey {
    static let defaultValue: KeywordCategoryClassifier = KeywordCategoryClassifier()
}

// MARK: - Add Expense Presenter

/// A closure injected by AppShell so feature views can present AddExpenseSheet
/// without creating a cross-module dependency on FeatureAddExpense.
public typealias AddExpensePresenter = (@escaping () -> Void) -> AnyView

private struct AddExpensePresenterKey: EnvironmentKey {
    static let defaultValue: AddExpensePresenter = { _ in AnyView(EmptyView()) }
}

// MARK: - EnvironmentValues Extensions

public extension EnvironmentValues {
    var expenseService: any ExpenseServiceProtocol {
        get { self[ExpenseServiceKey.self] }
        set { self[ExpenseServiceKey.self] = newValue }
    }

    var budgetService: any BudgetServiceProtocol {
        get { self[BudgetServiceKey.self] }
        set { self[BudgetServiceKey.self] = newValue }
    }

    var insightEngine: any InsightEngineProtocol {
        get { self[InsightEngineKey.self] }
        set { self[InsightEngineKey.self] = newValue }
    }

    var fxService: any FXServiceProtocol {
        get { self[FXServiceKey.self] }
        set { self[FXServiceKey.self] = newValue }
    }

    var categoryService: any CategoryServiceProtocol {
        get { self[CategoryServiceKey.self] }
        set { self[CategoryServiceKey.self] = newValue }
    }

    var classifier: KeywordCategoryClassifier {
        get { self[ClassifierKey.self] }
        set { self[ClassifierKey.self] = newValue }
    }

    var addExpensePresenter: AddExpensePresenter {
        get { self[AddExpensePresenterKey.self] }
        set { self[AddExpensePresenterKey.self] = newValue }
    }
}

// MARK: - No-Op Implementations (used as environment defaults)

private struct NoOpExpenseService: ExpenseServiceProtocol {
    func create(_ new: NewExpense) async throws {}
    func update(id: UUID, with new: NewExpense) async throws {}
    func delete(id: UUID) async throws {}
    func fetch(in range: DateInterval) async throws -> [ExpenseDTO] { [] }
    func total(in range: DateInterval, categoryID: UUID?) async throws -> Decimal { .zero }
}

private struct NoOpBudgetService: BudgetServiceProtocol {
    func current(for date: Date) async throws -> [BudgetDTO] { [] }
    func create(categoryID: UUID, limit: Decimal, period: BudgetPeriod) async throws {}
    func update(id: UUID, limit: Decimal) async throws {}
    func delete(id: UUID) async throws {}
}

private struct NoOpInsightEngine: InsightEngineProtocol {
    func weeklyTrend(endingOn date: Date) async throws -> [DailySpend] { [] }
    func categoryBreakdown(in range: DateInterval) async throws -> [CategorySpend] { [] }
    func smartTips(for date: Date) async throws -> [SmartTip] { [] }
}

private struct NoOpFXService: FXServiceProtocol {
    func rate(from: CurrencyCode, to: CurrencyCode, on date: Date) async throws -> Decimal { 1 }
    func convert(_ amount: Decimal, from: CurrencyCode, to: CurrencyCode, on date: Date) async throws -> Decimal { amount }
}

private struct NoOpCategoryService: CategoryServiceProtocol {
    func fetchAll() async throws -> [CategoryDTO] { [] }
}
