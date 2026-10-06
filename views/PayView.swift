import SwiftUI
import UIKit

enum UPIApp: String, CaseIterable, Identifiable {
    case gpay = "Google Pay"
    case phonepe = "PhonePe"
    case paytm = "Paytm"
    case cred = "CRED"
    case any = "Other UPI app"

    var id: String { rawValue }

    private var scheme: String {
        switch self {
        case .gpay: return "gpay"
        case .phonepe: return "phonepe"
        case .paytm: return "paytmmp"
        case .cred: return "credpay"
        case .any: return "upi"
        }
    }

    private var host: String {
        switch self {
        case .gpay, .cred: return "upi"
        case .phonepe, .paytm, .any: return "pay"
        }
    }

    private var path: String {
        switch self {
        case .gpay, .cred: return "/pay"
        default: return ""
        }
    }

    var isInstalled: Bool {
        guard let url = URL(string: "\(scheme)://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    func paymentURL(upiID: String, name: String, amount: Double, note: String) -> URL? {
        var comps = URLComponents()
        comps.scheme = scheme
        comps.host = host
        comps.path = path
        var items = [
            URLQueryItem(name: "pa", value: upiID),
            URLQueryItem(name: "pn", value: name.isEmpty ? upiID : name),
            URLQueryItem(name: "am", value: String(format: "%.2f", amount)),
            URLQueryItem(name: "cu", value: "INR")
        ]
        if !note.isEmpty {
            items.append(URLQueryItem(name: "tn", value: String(note.prefix(50))))
        }
        comps.queryItems = items
        return comps.url
    }
}

struct PendingPayment {
    let app: UPIApp
    let amount: Double
    let payee: String
    let time: Date
}

struct PayView: View {
    @ObservedObject var store: ExpenseStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var upiID = ""
    @State private var payeeName = ""
    @State private var amountText = ""
    @State private var note = ""
    @State private var category: ExpenseCategory = .other
    @State private var recordExpense = true

    @State private var pending: PendingPayment?
    @State private var leftApp = false
    @State private var showConfirm = false
    @State private var confirmNote = ""
    @State private var errorMessage = ""

    private var installedApps: [UPIApp] {
        UPIApp.allCases.filter { $0.isInstalled }
    }

    var body: some View {
        NavigationStack {
            Form {
                payeeSection
                amountSection
                optionsSection
                payWithSection
            }
            .navigationTitle("Pay with UPI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                handleScenePhase(newPhase)
            }
            .alert("Did the payment go through?", isPresented: $showConfirm) {
                TextField("Note (optional)", text: $confirmNote)
                Button("Yes, save expense") { saveConfirmed() }
                Button("No, discard", role: .cancel) { pending = nil }
            } message: {
                Text("Add or edit a note, then save it to your expenses.")
            }
        }
    }

    // MARK: - Sections
    private var payeeSection: some View {
        Section("Pay to") {
            TextField("UPI ID (e.g. name@okaxis)", text: $upiID)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
            TextField("Name (optional)", text: $payeeName)
        }
    }

    private var amountSection: some View {
        Section("Amount and note") {
            TextField("Amount (₹)", text: $amountText)
                .keyboardType(.decimalPad)
            TextField("Note (e.g. Mess fees)", text: $note)
        }
    }

    private var optionsSection: some View {
        Section {
            Picker("Category", selection: $category) {
                ForEach(ExpenseCategory.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                }
            }
            Toggle("Save to my expenses", isOn: $recordExpense)
        } footer: {
            Text("Turn this off and SpendWise stores nothing about this payment.")
        }
    }

    private var payWithSection: some View {
        Section {
            if installedApps.isEmpty {
                Text("No UPI app found. Test this on a real iPhone with a UPI app installed.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(installedApps) { app in
                    Button {
                        pay(with: app)
                    } label: {
                        Label("Pay with \(app.rawValue)", systemImage: "indianrupeesign.circle.fill")
                    }
                }
            }
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Pay with")
        }
    }

    // MARK: - Logic
    private func pay(with app: UPIApp) {
        let cleanID = upiID.trimmingCharacters(in: .whitespaces)
        guard cleanID.contains("@"), !cleanID.contains(" ") else {
            errorMessage = "Enter a valid UPI ID."
            return
        }
        guard let amount = Double(amountText), amount > 0 else {
            errorMessage = "Enter a valid amount."
            return
        }
        let cleanNote = note.trimmingCharacters(in: .whitespaces)
        guard let url = app.paymentURL(upiID: cleanID, name: payeeName,
                                       amount: amount, note: cleanNote) else {
            errorMessage = "Could not create the payment link."
            return
        }
        errorMessage = ""

        if recordExpense {
            let name = payeeName.trimmingCharacters(in: .whitespaces)
            pending = PendingPayment(app: app, amount: amount,
                                     payee: name.isEmpty ? cleanID : name,
                                     time: Date())
            leftApp = false
        } else {
            pending = nil
        }

        UIApplication.shared.open(url) { success in
            if !success {
                DispatchQueue.main.async {
                    pending = nil
                    errorMessage = "Could not open \(app.rawValue)."
                }
            }
        }
    }

    private func handleScenePhase(_ phase: ScenePhase) {
        guard pending != nil else { return }
        if phase == .background {
            leftApp = true
        } else if phase == .active && leftApp {
            leftApp = false
            confirmNote = note
            showConfirm = true
        }
    }

    private func saveConfirmed() {
        guard let p = pending else { return }
        let expense = Expense(
            amount: p.amount,
            category: category,
            note: confirmNote.trimmingCharacters(in: .whitespaces),
            date: p.time,
            paidVia: p.app.rawValue,
            payee: p.payee
        )
        store.addExpense(expense)
        pending = nil
        dismiss()
    }
}
