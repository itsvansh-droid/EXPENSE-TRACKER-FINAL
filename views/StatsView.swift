import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var store: ExpenseStore

    var body: some View {
        NavigationStack {
            Group {
                if store.categoryTotals.isEmpty {
                    ContentUnavailableView(
                        "No data this month",
                        systemImage: "chart.pie",
                        description: Text("Add expenses to see your stats.")
                    )
                } else {
                    content
                }
            }
            .navigationTitle("Stats")
        }
    }

    private var content: some View {
        List {
            Section("This Month") {
                donutChart
                Text("Total: ₹\(store.monthTotal, specifier: "%.2f")")
                    .font(.headline)
            }
            Section("Breakdown") {
                ForEach(store.categoryTotals) { item in
                    breakdownRow(item)
                }
            }
        }
    }

    private var donutChart: some View {
        Chart(store.categoryTotals) { item in
            SectorMark(
                angle: .value("Amount", item.total),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .foregroundStyle(item.category.color)
        }
        .frame(height: 220)
        .padding(.vertical, 8)
    }

    private func breakdownRow(_ item: CategoryTotal) -> some View {
        let percent = store.monthTotal > 0 ? item.total / store.monthTotal * 100 : 0
        return HStack {
            Image(systemName: item.category.icon)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(item.category.color, in: Circle())
            Text(item.category.rawValue)
            Spacer()
            VStack(alignment: .trailing) {
                Text("₹\(item.total, specifier: "%.0f")")
                    .font(.headline)
                Text("\(percent, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
