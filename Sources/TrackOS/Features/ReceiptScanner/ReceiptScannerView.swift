import SwiftUI
import UIKit

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
                PhotoLibraryPicker { image in
                    Task { await viewModel.processImage(image) }
                }
            }
        }
    }

    // MARK: - Scan Prompt

    private var scanPrompt: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero visual
            ZStack {
                // Outer ring
                Circle()
                    .stroke(.blue.opacity(0.1), lineWidth: 40)
                    .frame(width: 200, height: 200)
                // Inner ring
                Circle()
                    .fill(.blue.opacity(0.06))
                    .frame(width: 140, height: 140)
                // Icon
                if viewModel.isProcessing {
                    ProgressView()
                        .controlSize(.large)
                        .tint(.blue)
                } else {
                    Image(systemName: "doc.viewfinder.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.blue)
                }
            }
            .padding(.bottom, 32)

            VStack(spacing: 10) {
                Text(viewModel.isProcessing ? "Analysing Receipt…" : "Scan a Receipt")
                    .font(.title2.bold())
                Text(viewModel.isProcessing
                     ? "Extracting merchant, amount and date"
                     : "Pick a photo — Vision OCR will extract\nmerchant, amount and date automatically.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
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

            // Tips footer
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                Text("Tip: Flat receipts in good lighting give the best results")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
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
            // Confidence banner
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("Receipt scanned — review and confirm details below")
                        .font(.subheadline)
                }
                .padding(4)
            }
            .listRowBackground(Color.green.opacity(0.07))

            // Extracted fields
            Section("Extracted Details") {
                HStack {
                    Label("Merchant", systemImage: "storefront")
                        .foregroundStyle(.secondary)
                    Spacer()
                    TextField("Merchant", text: $merchant)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Label("Amount", systemImage: "dollarsign.circle")
                        .foregroundStyle(.secondary)
                    Spacer()
                    TextField("0.00", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                DatePicker(selection: $date, displayedComponents: .date) {
                    Label("Date", systemImage: "calendar")
                        .foregroundStyle(.secondary)
                }
                Picker(selection: $category) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                        Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                    }
                } label: {
                    Label("Category", systemImage: "tag")
                        .foregroundStyle(.secondary)
                }
            }

            // Line items (expandable)
            if !receiptData.items.isEmpty {
                Section {
                    Button {
                        withAnimation { showLineItems.toggle() }
                    } label: {
                        HStack {
                            Text("Line Items (\(receiptData.items.count))")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: showLineItems ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if showLineItems {
                        ForEach(receiptData.items.prefix(20)) { item in
                            HStack {
                                Text(item.description).lineLimit(1)
                                Spacer()
                                if let a = item.amount {
                                    Text(a, format: .currency(code: currency))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.caption)
                        }
                    }
                }
            }

            // Actions
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
                        .foregroundStyle(.blue)
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
        .navigationTitle("Review Receipt")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Photo Picker

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
