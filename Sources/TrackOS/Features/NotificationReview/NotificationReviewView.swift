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
                    EmptyNotificationView { showPasteSheet = true }
                } else {
                    pendingList
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                if !notificationMonitor.pendingExpenses.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Dismiss All", role: .destructive) {
                            notificationMonitor.dismissAll()
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showPasteSheet = true
                    } label: {
                        Image(systemName: "doc.on.clipboard")
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

    private var pendingList: some View {
        List {
            ForEach(notificationMonitor.pendingExpenses) { parsed in
                PendingExpenseCard(
                    parsedExpense: parsed,
                    onApprove: { approve(parsed) },
                    onDismiss: { notificationMonitor.dismiss(parsed) }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

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
        notificationMonitor.dismiss(parsed)
    }
}

// MARK: - Empty State

private struct EmptyNotificationView: View {
    let onPaste: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("No Pending Notifications")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Financial notifications sent to TrackOS will appear here for review. You can also paste notification text manually.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            Button(action: onPaste) {
                Label("Paste Notification Text", systemImage: "doc.on.clipboard")
                    .padding()
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Pending Card

private struct PendingExpenseCard: View {
    let parsedExpense: ParsedExpense
    let onApprove: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: parsedExpense.category.icon)
                    .foregroundStyle(parsedExpense.category.color)

                Text(parsedExpense.merchant)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Spacer()

                Text(parsedExpense.amount, format: .currency(code: parsedExpense.currency))
                    .fontWeight(.bold)
            }

            HStack {
                Text(parsedExpense.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(parsedExpense.category.color.opacity(0.15))
                    .foregroundStyle(parsedExpense.category.color)
                    .clipShape(Capsule())

                Spacer()

                Text(parsedExpense.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !parsedExpense.rawText.isEmpty {
                Text(parsedExpense.rawText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 10) {
                Button(action: onDismiss) {
                    Text("Dismiss")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(.secondary.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button(action: onApprove) {
                    Text("Add Expense")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Paste Sheet

struct PasteNotificationView: View {
    @Binding var text: String
    let onParse: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Paste or type a financial notification below.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)

                TextEditor(text: $text)
                    .padding(8)
                    .frame(minHeight: 120)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Examples:").font(.caption).fontWeight(.semibold).foregroundStyle(.secondary)
                    Text("• \"You've spent $42.50 at Starbucks\"")
                    Text("• \"Chase: $150.00 charge at Amazon.com\"")
                    Text("• \"PayPal: Payment of $35.00 to Netflix\"")
                    Text("• \"€89.99 at H&M – tap to view\"")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer()

                Button(action: onParse) {
                    Text("Extract Expense")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .navigationTitle("Paste Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
