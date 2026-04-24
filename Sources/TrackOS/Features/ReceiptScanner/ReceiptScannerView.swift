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
                    ScanPromptView(
                        isProcessing: viewModel.isProcessing,
                        errorMessage: viewModel.errorMessage
                    ) {
                        viewModel.showImagePicker = true
                    }
                }
            }
            .navigationTitle("Scan Receipt")
            .sheet(isPresented: $viewModel.showImagePicker) {
                PhotoLibraryPicker { image in
                    Task { await viewModel.processImage(image) }
                }
            }
        }
    }
}

// MARK: - Prompt Screen

private struct ScanPromptView: View {
    let isProcessing: Bool
    let errorMessage: String?
    let onPickImage: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if isProcessing {
                ProgressView("Analyzing receipt…")
                    .controlSize(.large)
            } else {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)

                VStack(spacing: 8) {
                    Text("Scan a Receipt")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Choose a photo to automatically extract merchant, amount, and date.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                Button(action: onPickImage) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }

            Spacer()
        }
        .padding()
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
    @State private var selectedImageData: Data?

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
        Form {
            Section("Extracted Details") {
                TextField("Merchant", text: $merchant)
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("0.00", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                        Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                    }
                }
            }

            if !receiptData.items.isEmpty {
                Section("Line Items (\(receiptData.items.count))") {
                    ForEach(receiptData.items.prefix(15)) { item in
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

            Section {
                Button("Save Expense") {
                    let expense = Expense(
                        amount: amount,
                        currency: currency,
                        merchant: merchant.trimmingCharacters(in: .whitespaces),
                        category: category,
                        date: date,
                        source: .receipt,
                        rawSourceText: receiptData.rawText,
                        receiptImageData: selectedImageData
                    )
                    onSave(expense)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
                .disabled(merchant.trimmingCharacters(in: .whitespaces).isEmpty || amount <= 0)

                Button("Discard", role: .destructive, action: onDiscard)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Review Receipt")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Photo Library Picker

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

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
