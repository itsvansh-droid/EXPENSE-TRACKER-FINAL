import SwiftUI
import Charts

struct ContentView: View {
    @ObservedObject var store: ExpenseStore

    @State private var showingAdd = false
    @State private var editingExpense: Expense?
    @State private var showingBudgetAlert = false
    @State private var budgetText = ""
    @State private var showingPay = false

    @State private var fromDate: Date = ContentView.startOfThisMonth()
    @State private var toDate: Date = Date()

    // MARK: - Date range helpers
    private static func startOfThisMonth() -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
    }

    private var rangeStart: Date {
        Calendar.current.startOfDay(for: min(fromDate, toDate))
    }

    private var rangeEnd: Date {
        let latest = max(fromDate, toDate)
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: latest) ?? latest
    }

    private var rangeExpenses: [Expense] {
        store.expenses
            .filter { $0.date >= rangeStart && $0.date <= rangeEnd }
            .sorted { $0.date > $1.date }
    }

    private var rangeTotal: Double {
        rangeExpenses.reduce(0) { $0 + $1.amount }
    }

    private var rangeCategoryTotals: [CategoryTotal] {
        var result: [CategoryTotal] = []
        for cat in ExpenseCategory.allCases {
            let sum = rangeExpenses
                .filter { $0.category == cat }
                .reduce(0) { $0 + $1.amount }
            if sum > 0 {
                result.append(CategoryTotal(category: cat, total: sum))
            }
        }
        return result
    }

    private func setThisMonth() {
        fromDate = ContentView.startOfThisMonth()
        toDate = Date()
    }

    private func setLastMonth() {
        let cal = Calendar.current
        let startThis = ContentView.startOfThisMonth()
        fromDate = cal.date(byAdding: .month, value: -1, to: startThis) ?? startThis
        toDate = cal.date(byAdding: .day, value: -1, to: startThis) ?? startThis
    }

    private func setAllTime() {
        let earliest = store.expenses.map { $0.date }.min() ?? Date()
        let latest = store.expenses.map { $0.date }.max() ?? Date()
        fromDate = earliest
        toDate = max(latest, Date())
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                Section("Filter by Date") {
                    rangeCard
                }
                Section("This Month's Budget") {
                    budgetCard
                }
                if !rangeCategoryTotals.isEmpty {
                    Section("Spending by Category") {
                        chartCard
                    }
                }
                Section("Expenses in Range") {
                    expenseList
                }
            }
            .navigationTitle("SpendWise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingPay = true
                    } label: {
                        Label("Pay", systemImage: "indianrupeesign.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddExpenseView(store: store)
            }
            .sheet(isPresented: $showingPay) {
                PayView(store: store)
            }
            .sheet(item: $editingExpense) { expense in
                AddExpenseView(store: store, expenseToEdit: expense)
            }
            .alert("Set Monthly Budget", isPresented: $showingBudgetAlert) {
                TextField("Amount", text: $budgetText)
                    .keyboardType(.decimalPad)
                Button("Save") {
                    store.monthlyBudget = Double(budgetText) ?? 0
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("How much can you spend this month?")
            }
        }
    }

    // MARK: - Date Range Card
    private var rangeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            DatePicker("From", selection: $fromDate, displayedComponents: .date)
            DatePicker("To", selection: $toDate, displayedComponents: .date)

            HStack(spacing: 8) {
                Button("This Month") { setThisMonth() }
                Button("Last Month") { setLastMonth() }
                Button("All Time") { setAllTime() }
            }
            .font(.footnote)
            .buttonStyle(.borderless)

            Divider()

            Text("Total Spent")
                .foregroundStyle(.secondary)

            Text("₹\(rangeTotal, specifier: "%.2f")")
                .font(.system(size: 36, weight: .bold))

            Text("\(rangeExpenses.count) expense(s) in this period")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Budget Card
    private var progress: Double {
        guard store.monthlyBudget > 0 else { return 0 }
        return min(store.monthTotal / store.monthlyBudget, 1)
    }

    private var progressColor: Color {
        if progress >= 1 { return .red }
        if progress >= 0.8 { return .orange }
        return .green
    }

    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            if store.monthlyBudget > 0 {
                HStack {
                    Text("Spent: ₹\(store.monthTotal, specifier: "%.0f")")
                    Spacer()
                    Text("Budget: ₹\(store.monthlyBudget, specifier: "%.0f")")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)

                ProgressView(value: progress)
                    .tint(progressColor)

                if store.remaining >= 0 {
                    Text("₹\(store.remaining, specifier: "%.0f") left this month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Over budget by ₹\(-store.remaining, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } else {
                Text("No budget set yet.")
                    .foregroundStyle(.secondary)
            }

            Button(store.monthlyBudget > 0 ? "Change Budget" : "Set Budget") {
                budgetText = store.monthlyBudget > 0
                    ? String(Int(store.monthlyBudget)) : ""
                showingBudgetAlert = true
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Chart
    private var chartCard: some View {
        Chart(rangeCategoryTotals) { item in
            BarMark(
                x: .value("Amount", item.total),
                y: .value("Category", item.category.rawValue)
            )
            .foregroundStyle(item.category.color)
        }
        .frame(height: CGFloat(rangeCategoryTotals.count) * 40 + 20)
        .padding(.vertical, 4)
    }

    // MARK: - List
    @ViewBuilder
    private var expenseList: some View {
        if store.expenses.isEmpty {
            Text("No expenses yet. Tap + to add one.")
                .foregroundStyle(.secondary)
        } else if rangeExpenses.isEmpty {
            Text("No expenses between these dates.")
                .foregroundStyle(.secondary)
        } else {
            ForEach(rangeExpenses) { expense in
                ExpenseRow(expense: expense)
                    .contentShape(Rectangle())
                    .onTapGesture { editingExpense = expense }
            }
            .onDelete(perform: deleteRange)
        }
    }

    private func deleteRange(at offsets: IndexSet) {
        let ids = offsets.map { rangeExpenses[$0].id }
        store.expenses.removeAll { ids.contains($0.id) }
    }
}

struct ExpenseRow: View {
    let expense: Expense

    private var title: String {
        if !expense.note.isEmpty { return expense.note }
        return expense.payee ?? expense.category.rawValue
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(expense.category.color, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(expense.date, format: .dateTime.day().month().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let via = expense.paidVia {
                    Text("via \(via)")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }

            Spacer()

            Text("₹\(expense.amount, specifier: "%.2f")")
                .font(.headline)
        }
    }

}
