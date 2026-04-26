#if os(iOS)
import SwiftUI
import SwiftData

struct NotificationReviewView: View {
    @EnvironmentObject var notificationMonitor: NotificationMonitorService
    @Environment(\.modelContext) private var modelContext
    @State private var showPasteSheet = false
    @State private var pastedText = ""

    var body: some View {
        NavigationStack {
            Group {
                if notificationMonitor.pendingExpenses.isEmpty {
                    emptyState
                } else {
                    pendingList
                }
            }
            .background(Theme.background)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !notificationMonitor.pendingExpenses.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Clear All", role: .destructive) {
                            withAnimation { notificationMonitor.dismissAll() }
                        }
                        .font(.subheadline)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showPasteSheet = true
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundStyle(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showPasteSheet) {
                PasteNotificationView(text: $pastedText) {
                    notificationMonitor.parseAndQueue(text: pastedText)
                    pastedText = ""
                    showPasteSheet = false
                }
            }
        }
    }

    // MARK: - Pending List

    private var pendingList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.primary)
                    Text("\(notificationMonitor.pendingExpenses.count) expense\(notificationMonitor.pendingExpenses.count == 1 ? "" : "s") detected — review before saving")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                }
                .padding(14)
                .background(Theme.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                ForEach(notificationMonitor.pendingExpenses) { parsed in
                    PendingExpenseCard(
                        parsedExpense: parsed,
                        onApprove: { approve(parsed) },
                        onDismiss: { withAnimation { notificationMonitor.dismiss(parsed) } }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.primaryLight)
                    .frame(width: 96, height: 96)
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.primary.opacity(0.5))
            }
            VStack(spacing: 8) {
                Text("No Pending Notifications")
                    .font(.title3.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text("Financial notifications sent to TrackOS appear here.\nYou can also paste text from any banking app.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Button {
                showPasteSheet = true
            } label: {
                Label("Paste Notification", systemImage: "doc.on.clipboard")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(Theme.primary)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 4)
            }
            Spacer()
        }
    }

    // MARK: - Approve

    private func approve(_ parsed: ParsedExpense) {
        let expense = Expense(
            amount: parsed.amount,
            currency: parsed.currency,
            merchant: parsed.merchant,
            category: parsed.category,
            date: parsed.date,
            source: .notification,
            rawSourceText: parsed.rawText
        )
        modelContext.insert(expense)
        withAnimation { notificationMonitor.dismiss(parsed) }
    }
}

// MARK: - Pending Card

private struct PendingExpenseCard: View {
    let parsedExpense: ParsedExpense
    let onApprove: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(parsedExpense.category.color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: parsedExpense.category.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(parsedExpense.category.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(parsedExpense.merchant)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text(parsedExpense.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Text(parsedExpense.amount, format: .currency(code: parsedExpense.currency))
                    .font(.title3.bold())
                    .foregroundStyle(Theme.textPrimary)
            }

            HStack {
                Label(parsedExpense.category.rawValue, systemImage: parsedExpense.category.icon)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(parsedExpense.category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(parsedExpense.category.color.opacity(0.10))
                    .clipShape(Capsule())
                Spacer()
            }

            if !parsedExpense.rawText.isEmpty {
                Text("\"\(parsedExpense.rawText)\"")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.cardSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 10) {
                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.fill)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button(action: onApprove) {
                    Text("Add Expense")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.primaryDark.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Paste Sheet

struct PasteNotificationView: View {
    @Binding var text: String
    let onParse: () -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Paste bank or payment notification text below. TrackOS will extract the amount and merchant automatically.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                TextEditor(text: $text)
                    .focused($focused)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(14)
                    .frame(minHeight: 120)
                    .background(Theme.cardSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Examples")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                    ForEach([
                        "Maybank: RM42.50 charged at Starbucks",
                        "Grab: RM14.00 GrabCar ride completed",
                        "Chase: $150.00 charge at Amazon.com",
                        "WeChat Pay: RMB88.00 at Hema",
                    ], id: \.self) { example in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "text.quote")
                                .font(.caption)
                                .foregroundStyle(Theme.textTertiary)
                                .padding(.top, 1)
                            Text(example)
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .padding(14)
                .background(Theme.primaryLight.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Spacer()

                Button(action: onParse) {
                    Text("Extract Expense")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(text.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.fill : Theme.primary)
                        .foregroundStyle(text.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.textTertiary : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(20)
            .background(Theme.background)
            .navigationTitle("Paste Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .onAppear { focused = true }
        }
    }
}
#endif
