import Foundation
import SwiftUI

struct CategoryTotal: Identifiable {
    let category: ExpenseCategory
    let total: Double
    var id: String { category.rawValue }
}

class ExpenseStore: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet { save() }
    }

    @Published var monthlyBudget: Double = 0 {
        didSet { UserDefaults.standard.set(monthlyBudget, forKey: budgetKey) }
    }

    private let storageKey = "saved_expenses"
    private let budgetKey = "monthly_budget"

    init() {
        load()
        monthlyBudget = UserDefaults.standard.double(forKey: budgetKey)
    }

    var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var thisMonthExpenses: [Expense] {
        expenses.filter {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month)
        }
    }

    var monthTotal: Double {
        thisMonthExpenses.reduce(0) { $0 + $1.amount }
    }

    var remaining: Double {
        monthlyBudget - monthTotal
    }

    var categoryTotals: [CategoryTotal] {
        var result: [CategoryTotal] = []
        for cat in ExpenseCategory.allCases {
            let sum = thisMonthExpenses
                .filter { $0.category == cat }
                .reduce(0) { $0 + $1.amount }
            if sum > 0 {
                result.append(CategoryTotal(category: cat, total: sum))
            }
        }
        return result
    }

    func addExpense(_ expense: Expense) {
        expenses.insert(expense, at: 0)
    }
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
        }
    }

    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Expense].self, from: data)
        else { return }
        expenses = decoded
    }
}
