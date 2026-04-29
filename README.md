# TrackOS

A production-grade iOS expense tracker built with a strict SPM modular architecture. Dark-first design with a `#B6FF3D` accent, SwiftData persistence, and keyword-based auto-categorisation.

## Screenshots

<table>
  <tr>
    <td align="center">
      <img src="screenshots/dashboard.svg" width="200" alt="Dashboard"/>
      <br/><sub><b>Dashboard</b></sub>
    </td>
    <td align="center">
      <img src="screenshots/insights.svg" width="200" alt="Insights"/>
      <br/><sub><b>Insights</b></sub>
    </td>
    <td align="center">
      <img src="screenshots/add-expense.svg" width="200" alt="Add Expense"/>
      <br/><sub><b>Add Expense</b></sub>
    </td>
    <td align="center">
      <img src="screenshots/budgets.svg" width="200" alt="Budgets"/>
      <br/><sub><b>Budgets</b></sub>
    </td>
  </tr>
</table>

## Features

- **Dashboard** — balance card, period picker (week / month / year), recent expense list with pull-to-refresh, FAB to add expense.
- **Insights** — 7-day bar chart, category breakdown with percentage bars, smart tips triggered by budget thresholds.
- **Add Expense** — amount + currency picker, merchant field, date picker, horizontal category chip row (auto-predicted by keyword classifier), optional note.
- **Budgets** — overview rings per category, per-budget progress bars, exceeded-budget highlighting.
- **Keyword Classifier** — rule-based merchant → category inference, configurable via `KeywordCategoryClassifier.updateCategories(_:)`.
- **FX Service** — hardcoded mid-market rates vs MYR (Phase 3 v1, swap `FXService.client` for live data).

## Requirements

- iOS 17+ / Xcode 16+
- Swift 5.9+

## Architecture

Strict SPM module separation — compiler enforces layer boundaries:

```
Sources/
├── Domain/           Pure Foundation: DTOs, protocols, errors, classifier, validation
├── Persistence/      SwiftData @Model, @ModelActor repos, services, FX, seeding
├── DesignSystem/     SwiftUI tokens (Theme, Color, Space, Radius, Font), components,
│                     surface modifier, service EnvironmentKey extensions
├── FeatureDashboard/ DashboardView + DashboardModel  (→ Domain + DesignSystem)
├── FeatureInsights/  InsightsView + InsightsModel    (→ Domain + DesignSystem)
├── FeatureAddExpense/AddExpenseSheet + AddExpenseModel(→ Domain + DesignSystem)
├── FeatureBudgets/   BudgetsView + BudgetsModel      (→ Domain + DesignSystem)
└── AppShell/         AppComposition, RootView, AppRouter  (→ all modules)
```

**Dependency rule**: `Domain → Foundation only` · `Features → Domain + DesignSystem only` · cross-feature dependencies forbidden · `AppShell` is the sole composition root.

**Cross-feature sheet presentation**: `DashboardView` reads `@Environment(\.addExpensePresenter)` — a factory closure injected by `AppShell`. No direct feature-to-feature imports.

## Xcode Project Setup

TrackOS ships as a Swift package. To embed it in an Xcode iOS app target:

1. Create a new **iOS App** project in Xcode (SwiftUI, no SwiftData template needed).
2. **File → Add Package Dependencies** → add this local package.
3. Link the `AppShell` product to your app target.
4. In your `@main` App struct, host `TrackOSApp` (from AppShell) or compose `RootView` directly.
5. Add capabilities: **Push Notifications**, **Background Modes → Background fetch**.
6. Add to `Info.plist`: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`.

## Running Tests

```bash
# Domain logic (no simulator required)
swift test --filter DomainTests

# Persistence layer (in-memory SwiftData container)
swift test --filter PersistenceTests

# AddExpense view model
swift test --filter FeatureAddExpenseTests
```

## CI

GitHub Actions runs on `macos-15` + Xcode 16:

1. **Unit Tests** — `DomainTests`, `PersistenceTests`, `FeatureAddExpenseTests` via `swift test`.
2. **iOS Build Check** — all SPM targets compiled for Mac Catalyst (`platform=macOS,variant=Mac Catalyst`) since the iOS SDK is not pre-installed on the runner.

See [CLAUDE.md](CLAUDE.md) for deeper architectural notes.
