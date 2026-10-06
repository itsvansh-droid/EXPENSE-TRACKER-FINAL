import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var store: ExpenseStore
    var expenseToEdit: Expense? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var amount = ""
    @State private var category: ExpenseCategory = .food
    @State private var note = ""
    @State private var date = Date()

    private var isValid: Bool {
        (Double(amount) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                categorySection
            }
            .navigationTitle(expenseToEdit == nil ? "Add Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveExpense() }
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            TextField("Note (e.g. Lunch)", text: $note)
            DatePicker("Date", selection: $date, displayedComponents: .date)
        }
    }

    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: $category) {
                ForEach(ExpenseCategory.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                }
            }
        }
    }

    private func loadIfEditing() {
        guard let expense = expenseToEdit else { return }
        amount = String(expense.amount)
        category = expense.category
        note = expense.note
        date = expense.date
    }

    private func saveExpense() {
        guard let value = Double(amount) else { return }

        if var existing = expenseToEdit {
            existing.amount = value
            existing.category = category
            existing.note = note
            existing.date = date
            store.updateExpense(existing)
        } else {
            let newExpense = Expense(
                amount: value,
                category: category,
                note: note,
                date: date
            )
            store.addExpense(newExpense)
        }
        dismiss()
    }
}
