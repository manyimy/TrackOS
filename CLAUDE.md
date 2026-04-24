# TrackOS

iOS expense tracking app that automatically captures expenses from financial notifications and receipt images.

## Tech Stack

- **Swift / SwiftUI** — UI framework (iOS 17+)
- **SwiftData** — local persistence
- **Vision** framework — receipt OCR (`VNRecognizeTextRequest`)
- **UserNotifications** — notification monitoring + permission management

## Architecture

MVVM with a service layer. SwiftData model container is set up at app launch and injected via the environment.

```
Sources/TrackOS/
├── App/              # @main entry point, root TabView
├── Models/           # SwiftData model (Expense), value types (ExpenseCategory, ExpenseSource, ParsedExpense)
├── Services/
│   ├── NotificationParserService   # Regex-based financial text parser
│   ├── NotificationMonitorService  # UNUserNotificationCenter delegate + pending expense queue
│   └── ReceiptOCRService           # Vision OCR pipeline + receipt field extraction
├── Features/
│   ├── Dashboard/         # Monthly summary + category breakdown
│   ├── ExpenseList/       # Searchable/filterable expense list
│   ├── AddExpense/        # Manual entry form
│   ├── ReceiptScanner/    # Image picker → OCR → review flow
│   └── NotificationReview/# Pending parsed expenses from notifications
└── Utilities/             # Extensions (Collection safe subscript, Date helpers)
```

## Key Design Decisions

### Notification Parsing
iOS sandboxing prevents reading other apps' notifications directly. The two supported flows are:

1. **Push notifications to TrackOS** — a backend service (e.g. Plaid webhook → your server → APNS) sends parsed financial data as push notifications to this app. `NotificationMonitorService` receives them via `UNUserNotificationCenterDelegate`.
2. **Manual paste / Shortcuts** — users paste notification text into the app, or use an iOS Shortcut with the URL scheme `trackos://expense?text=<text>` to trigger parsing automatically.

`NotificationParserService` handles both paths with regex patterns covering major bank/payment app formats.

### Receipt OCR
`ReceiptOCRService` uses `VNRecognizeTextRequest` at `.accurate` level. Parsed fields (merchant, total, date, line items) are shown in an editable review screen before saving — OCR is never silently trusted.

### Data Layer
`Expense` is a SwiftData `@Model`. Receipt image data uses `@Attribute(.externalStorage)` to keep the SQLite store lean. All category/source info is stored as raw strings and surfaced as typed enums via computed properties.

## Setup in Xcode

1. Create a new project: **iOS App → SwiftUI + SwiftData** template
2. Set deployment target to **iOS 17.0+**
3. Add all files from `Sources/TrackOS/` to the project target
4. Add capabilities: **Push Notifications**, **Background Modes → Background fetch**
5. Register URL scheme `trackos` in Info.plist under `CFBundleURLTypes`
6. Add Info.plist keys:
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription`

## Running Tests

```bash
# Requires macOS 14+ / Xcode 15+
swift test
```

Tests cover `NotificationParserService` parsing logic (no UIKit/SwiftData needed).

## URL Scheme (Shortcuts Integration)

```
trackos://expense?text=<url-encoded notification text>
```

Example Shortcut: trigger on notification from Chase app → URL action → `trackos://expense?text=[Notification Content]`

## Notification Text Formats Supported

- `"You've spent $42.50 at Starbucks"`
- `"Chase: $150.00 charge at Amazon.com"`
- `"Payment of $35.00 to Netflix confirmed"`
- `"MERCHANT charged $XX.XX to your Visa"`
- `"You sent $15.00 to John via Venmo"`
- `"€89.99 at H&M – tap to view"`
