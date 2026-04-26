#if os(iOS)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ReceiptScannerView: View {
    @StateObject private var viewModel = ReceiptScannerViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if let result = viewModel.scannedData {
                    ReceiptReviewView(receiptData: result) { expense in
                        modelContext.insert(expense)
                        viewModel.clear()
                    } onDiscard: {
                        viewModel.clear()
                    }
                } else {
                    scanPrompt
                }
            }
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showImagePicker) {
#if canImport(UIKit)
                PhotoLibraryPicker { image in
                    Task { await viewModel.processImage(image) }
                }
#else
                EmptyView()
#endif
            }
        }
    }

    // MARK: - Scan Prompt

    private var scanPrompt: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.primaryLight.opacity(0.5))
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(Theme.primaryLight)
                    .frame(width: 140, height: 140)
                if viewModel.isProcessing {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Theme.primary)
                } else {
                    Image(systemName: "doc.viewfinder.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.primary)
                }
            }
            .padding(.bottom, 32)

            VStack(spacing: 10) {
                Text(viewModel.isProcessing ? "Analysing Receipt…" : "Scan a Receipt")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text(viewModel.isProcessing
                     ? "Extracting merchant, amount and date"
                     : "Pick a photo — Vision OCR will extract\nmerchant, amount and date automatically.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 36)

            if !viewModel.isProcessing {
                VStack(spacing: 12) {
                    Button {
                        viewModel.showImagePicker = true
                    } label: {
                        Label("Choose from Library", systemImage: "photo.on.rectangle.angled")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 32)

                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 32)
                    }
                }
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                Text("Tip: Flat receipts in good lighting give the best results")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Theme.background)
    }
}

// MARK: - Review Screen

struct ReceiptReviewView: View {
    let receiptData: ReceiptOCRService.ReceiptData
    let onSave: (Expense) -> Void
    let onDiscard: () -> Void

    @State private var merchant: String
    @State private var amount: Double
    @State private var currency: String
    @State private var category: ExpenseCategory = .other
    @State private var date: Date
    @State private var showLineItems = false

    init(
        receiptData: ReceiptOCRService.ReceiptData,
        onSave: @escaping (Expense) -> Void,
        onDiscard: @escaping () -> Void
    ) {
        self.receiptData = receiptData
        self.onSave = onSave
        self.onDiscard = onDiscard
        _merchant = State(initialValue: receiptData.merchant ?? "")
        _amount = State(initialValue: receiptData.amount ?? 0)
        _currency = State(initialValue: receiptData.currency)
        _date = State(initialValue: receiptData.date ?? Date())
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("Receipt scanned — review and confirm details below")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(4)
            }
            .listRowBackground(Color.green.opacity(0.06))

            Section("Extracted Details") {
                HStack {
                    Label("Merchant", systemImage: "storefront")
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    TextField("Merchant", text: $merchant)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Theme.textPrimary)
                }
                HStack {
                    Label("Amount", systemImage: "dollarsign.circle")
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    TextField("0.00", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 100)
                }
                DatePicker(selection: $date, displayedComponents: .date) {
                    Label("Date", systemImage: "calendar")
                        .foregroundStyle(Theme.textSecondary)
                }
                .tint(Theme.primary)
                Picker(selection: $category) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                        Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                    }
                } label: {
                    Label("Category", systemImage: "tag")
                        .foregroundStyle(Theme.textSecondary)
                }
                .tint(Theme.primary)
            }

            if !receiptData.items.isEmpty {
                Section {
                    Button {
                        withAnimation { showLineItems.toggle() }
                    } label: {
                        HStack {
                            Text("Line Items (\(receiptData.items.count))")
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Image(systemName: showLineItems ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }

                    if showLineItems {
                        ForEach(receiptData.items.prefix(20)) { item in
                            HStack {
                                Text(item.description)
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineLimit(1)
                                Spacer()
                                if let a = item.amount {
                                    Text(a, format: .currency(code: currency))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                            .font(.caption)
                        }
                    }
                }
            }

            Section {
                Button {
                    let expense = Expense(
                        amount: amount,
                        currency: currency,
                        merchant: merchant.trimmingCharacters(in: .whitespaces),
                        category: category,
                        date: date,
                        source: .receipt,
                        rawSourceText: receiptData.rawText
                    )
                    onSave(expense)
                } label: {
                    Label("Save Expense", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Theme.primary)
                        .fontWeight(.semibold)
                }
                .disabled(merchant.trimmingCharacters(in: .whitespaces).isEmpty || amount <= 0)

                Button(role: .destructive) {
                    onDiscard()
                } label: {
                    Label("Discard", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("Review Receipt")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Photo Picker (iOS only)

#if canImport(UIKit)
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoLibraryPicker
        init(_ parent: PhotoLibraryPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { parent.onImageSelected(image) }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif
#endif
