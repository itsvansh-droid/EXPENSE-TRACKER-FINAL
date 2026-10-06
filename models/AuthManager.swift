import Foundation
import SwiftUI
import CryptoKit

struct UserAccount: Codable {
    var name: String
    var email: String
    var passwordHash: String
}

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var currentName: String

    private static let usersKey = "saved_users"
    private static let sessionKey = "logged_in_email"

    init() {
        let savedEmail = UserDefaults.standard.string(forKey: AuthManager.sessionKey)
        self.isLoggedIn = savedEmail != nil
        self.currentName = ""
        if let savedEmail = savedEmail,
           let user = AuthManager.loadUsers()[savedEmail] {
            self.currentName = user.name
        }
    }

    // Returns an error message, or nil if successful
    func signUp(name: String, email: String, password: String) -> String? {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        let cleanName = name.trimmingCharacters(in: .whitespaces)

        if cleanName.isEmpty { return "Please enter your name." }
        if !cleanEmail.contains("@") || !cleanEmail.contains(".") {
            return "Please enter a valid email."
        }
        if password.count < 6 { return "Password must be at least 6 characters." }

        var users = AuthManager.loadUsers()
        if users[cleanEmail] != nil { return "An account with this email already exists." }

        users[cleanEmail] = UserAccount(
            name: cleanName,
            email: cleanEmail,
            passwordHash: AuthManager.hash(password)
        )
        AuthManager.saveUsers(users)
        startSession(email: cleanEmail, name: cleanName)
        return nil
    }

    // Returns an error message, or nil if successful
    func login(email: String, password: String) -> String? {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        if cleanEmail.isEmpty || password.isEmpty {
            return "Please enter email and password."
        }

        guard let user = AuthManager.loadUsers()[cleanEmail] else {
            return "No account found. Please create one."
        }
        if user.passwordHash != AuthManager.hash(password) {
            return "Incorrect password."
        }
        startSession(email: cleanEmail, name: user.name)
        return nil
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: AuthManager.sessionKey)
        currentName = ""
        isLoggedIn = false
    }

    private func startSession(email: String, name: String) {
        UserDefaults.standard.set(email, forKey: AuthManager.sessionKey)
        currentName = name
        isLoggedIn = true
    }

    private static func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func loadUsers() -> [String: UserAccount] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([String: UserAccount].self, from: data)
        else { return [:] }
        return users
    }

    private static func saveUsers(_ users: [String: UserAccount]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
}
