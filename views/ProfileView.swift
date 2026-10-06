import SwiftUI

struct ProfileView: View {
    @ObservedObject var store: ExpenseStore
    @EnvironmentObject var auth: AuthManager

    @State private var exportURL: URL?
    @State private var showingExportError = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(auth.currentName.isEmpty ? "Student" : auth.currentName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("SpendWise member")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Summary") {
                    row("Total expenses recorded", "\(store.expenses.count)")
                    row("Spent this month", "₹\(Int(store.monthTotal))")
                    row("Monthly budget",
                        store.monthlyBudget > 0 ? "₹\(Int(store.monthlyBudget))" : "Not set")
                }

                Section {
                    Button {
                        exportCSV()
                    } label: {
                        Label("Export to CSV", systemImage: "square.and.arrow.up")
                    }
                    .disabled(store.expenses.isEmpty)
                } header: {
                    Text("Report")
                } footer: {
                    Text("Exports all expenses as a spreadsheet file.")
                }

                Section {
                    Button("Log Out", role: .destructive) {
                        auth.logout()
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(item: $exportURL) { url in
                ShareSheet(items: [url])
            }
            .alert("Export failed", isPresented: $showingExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Could not create the CSV file.")
            }
        }
    }

    private func exportCSV() {
        if let url = CSVExporter.makeFile(from: store.expenses) {
            exportURL = url
        } else {
            showingExportError = true
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}
