import Foundation
import SwiftData
import Domain
import Persistence

/// Builds and owns all service instances for the lifetime of the app.
@MainActor
public final class AppComposition {

    public let modelContainer: ModelContainer
    public let expenseService: any ExpenseServiceProtocol
    public let budgetService: any BudgetServiceProtocol
    public let categoryService: any CategoryServiceProtocol
    public let insightEngine: any InsightEngineProtocol
    public let fxService: any FXServiceProtocol
    public let classifier: KeywordCategoryClassifier
    public let syncService: any RemoteSyncServiceProtocol

    public init(syncConfig: SyncConfiguration? = nil) throws {
        let schema = Schema(TrackOSSchema.models)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        modelContainer = try ModelContainer(for: schema, configurations: config)

        let expenseRepo  = ExpenseRepository(modelContainer: modelContainer)
        let categoryRepo = CategoryRepository(modelContainer: modelContainer)
        let budgetRepo   = BudgetRepository(modelContainer: modelContainer)

        let fx           = FXService()
        let clf          = KeywordCategoryClassifier()
        let sync         = RemoteSyncService(repo: expenseRepo, config: syncConfig)

        fxService       = fx
        classifier      = clf
        syncService     = sync
        expenseService  = ExpenseService(repo: expenseRepo, fx: fx, classifier: clf, sync: sync)
        categoryService = CategoryService(repo: categoryRepo)
        budgetService   = BudgetService(budgetRepo: budgetRepo, expenseRepo: expenseRepo)
        insightEngine   = InsightEngine(expenseRepo: expenseRepo, budgetRepo: budgetRepo)

        Task { @MainActor [weak self] in
            guard let self else { return }
            try? await categoryRepo.seed(defaults: CategorySeeder.defaults)
            if let map = try? await categoryRepo.nameToIDMap() {
                self.classifier.updateCategories(map)
            }
            // Pull any server-side changes that arrived since last launch
            await sync.sync()
        }
    }
}
