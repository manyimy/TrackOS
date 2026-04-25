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
            .background(Color(.systemGroupedBackground))
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
                // Summary banner
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.blue)
                    Text("\(notificationMonitor.pendingExpenses.count) expense\(notificationMonitor.pendingExpenses.count == 1 ? "" : "s") detected — review before saving")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(14)
                .background(.blue.opacity(0.07))
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
                    .fill(.blue.opacity(0.08))
                    .frame(width: 96, height: 96)
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue.opacity(0.5))
            }
            VStack(spacing: 8) {
                Text("No Pending Notifications")
                    .font(.title3.bold())
                Text("Financial notifications sent to TrackOS appear here.\nYou can also paste text from any banking app.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 4)
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
            // Top row: icon + merchant + amount
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(parsedExpense.category.color.opacity(0.14))
                        .frame(width: 44, height: 44)
                    Image(systemName: parsedExpense.category.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(parsedExpense.category.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(parsedExpense.merchant)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(parsedExpense.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(parsedExpense.amount, format: .currency(code: parsedExpense.currency))
                    .font(.title3.bold())
            }

            // Category tag
            HStack {
                Label(parsedExpense.category.rawValue, systemImage: parsedExpense.category.icon)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(parsedExpense.category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(parsedExpense.category.color.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()
            }

            // Raw text preview
            if !parsedExpense.rawText.isEmpty {
                Text("\"\(parsedExpense.rawText)\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Action buttons
            HStack(spacing: 10) {
                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button(action: onApprove) {
                    Text("Add Expense")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
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
                // Instructions
                VStack(alignment: .leading, spacing: 6) {
                    Text("Paste bank or payment notification text below. TrackOS will extract the amount and merchant automatically.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Text input
                TextEditor(text: $text)
                    .focused($focused)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(14)
                    .frame(minHeight: 120)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Examples
                VStack(alignment: .leading, spacing: 8) {
                    Text("Examples")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach([
                        "Maybank: RM42.50 charged at Starbucks",
                        "Grab: RM14.00 GrabCar ride completed",
                        "Chase: $150.00 charge at Amazon.com",
                        "WeChat Pay: RMB88.00 at Hema",
                    ], id: \.self) { example in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "text.quote")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 1)
                            Text(example)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(14)
                .background(Color(.systemFill))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Spacer()

                // Parse button
                Button(action: onParse) {
                    Text("Extract Expense")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(text.trimmingCharacters(in: .whitespaces).isEmpty ? Color(.systemFill) : .blue)
                        .foregroundStyle(text.trimmingCharacters(in: .whitespaces).isEmpty ? Color(.tertiaryLabel) : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Paste Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { focused = true }
        }
    }
}
