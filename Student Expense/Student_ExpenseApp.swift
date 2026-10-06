import SwiftUI

@main
struct Student_ExpenseApp: App {
    @StateObject private var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                MainTabView()
                    .environmentObject(auth)
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
    }
}
