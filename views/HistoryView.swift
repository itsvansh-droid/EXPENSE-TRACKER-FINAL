import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: ExpenseStore
    @State private var searchText = ""
    @State private var editingExpense: Expense?

    private var filteredExpenses: [Expense] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if query.isEmpty { return store.expenses }
        return store.expenses.filter {
            $0.note.lowercased().contains(query) ||
            $0.category.rawValue.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.expenses.isEmpty {
                    ContentUnavailableView(
                        "No expenses yet",
                        systemImage: "wallet.pass",
                        description: Text("Add an expense from the Home tab.")
                    )
                } else {
                    list
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search expenses")
            .sheet(item: $editingExpense) { expense in
                AddExpenseView(store: store, expenseToEdit: expense)
            }
        }
    }

    private var list: some View {
        List {
            ForEach(filteredExpenses) { expense in
                ExpenseRow(expense: expense)
                    .contentShape(Rectangle())
                    .onTapGesture { editingExpense = expense }
            }
            .onDelete(perform: delete)
        }
    }

    private func delete(at offsets: IndexSet) {
        let ids = offsets.map { filteredExpenses[$0].id }
        store.expenses.removeAll { ids.contains($0.id) }
    }
}
