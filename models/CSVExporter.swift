import Foundation
import SwiftUI
import UIKit

enum CSVExporter {
    static func makeFile(from expenses: [Expense]) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "HH:mm"

        var lines = ["Date,Time,Category,Note,Amount,Payee,Paid Via"]

        let sorted = expenses.sorted { $0.date < $1.date }
        for e in sorted {
            let fields = [
                dateFormatter.string(from: e.date),
                timeFormatter.string(from: e.date),
                e.category.rawValue,
                e.note,
                String(format: "%.2f", e.amount),
                e.payee ?? "",
                e.paidVia ?? ""
            ]
            lines.append(fields.map(escape).joined(separator: ","))
        }

        // BOM at the start makes Excel read the file as UTF-8
        let csv = "\u{FEFF}" + lines.joined(separator: "\n")

        let stamp = DateFormatter()
        stamp.locale = Locale(identifier: "en_US_POSIX")
        stamp.dateFormat = "yyyy-MM-dd"
        let fileName = "SpendWise-Expenses-\(stamp.string(from: Date())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func escape(_ field: String) -> String {
        let needsQuotes = field.contains(",") || field.contains("\"") || field.contains("\n")
        let cleaned = field.replacingOccurrences(of: "\"", with: "\"\"")
        return needsQuotes ? "\"\(cleaned)\"" : cleaned
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
