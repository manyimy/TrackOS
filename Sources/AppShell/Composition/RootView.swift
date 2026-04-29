import SwiftUI
import Domain
import DesignSystem
import FeatureDashboard
import FeatureInsights
import FeatureBudgets
import FeatureAddExpense

public struct RootView: View {
    @Environment(\.theme) private var theme
    @State private var router = AppRouter()
    private let composition: AppComposition

    public init(composition: AppComposition) {
        self.composition = composition
    }

    public var body: some View {
        @Bindable var bindableRouter = router
        return TabView(selection: $bindableRouter.selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house") }
                .tag(Tab.dashboard)

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }
                .tag(Tab.insights)

            BudgetsView()
                .tabItem { Label("Budgets", systemImage: "chart.pie") }
                .tag(Tab.budgets)
        }
        .tint(theme.color.accent)
        .environment(\.expenseService, composition.expenseService)
        .environment(\.budgetService, composition.budgetService)
        .environment(\.categoryService, composition.categoryService)
        .environment(\.insightEngine, composition.insightEngine)
        .environment(\.fxService, composition.fxService)
        .environment(\.classifier, composition.classifier)
        .environment(\.addExpensePresenter, makeAddExpensePresenter())
    }

    private func makeAddExpensePresenter() -> AddExpensePresenter {
        let expenseService = composition.expenseService
        let categoryService = composition.categoryService
        let classifier = composition.classifier
        return { onDismiss in
            AnyView(AddExpenseSheet(
                service: expenseService,
                categoryService: categoryService,
                classifier: classifier,
                onDismiss: onDismiss
            ))
        }
    }
}
