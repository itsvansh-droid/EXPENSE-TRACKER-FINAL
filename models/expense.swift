import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case food = "Food"
    case transport = "Transport"
    case books = "Books"
    case rent = "Rent"
    case fun = "Fun"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "bus"
        case .books: return "book"
        case .rent: return "house"
        case .fun: return "gamecontroller"
        case .other: return "ellipsis.circle"
        }
    }

    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .books: return .purple
        case .rent: return .green
        case .fun: return .pink
        case .other: return .gray
        }
    }
}

struct Expense: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var category: ExpenseCategory
    var note: String
    var date: Date
    var paidVia: String? = nil
    var payee: String? = nil
}

