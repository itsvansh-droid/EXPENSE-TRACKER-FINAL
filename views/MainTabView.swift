import SwiftUI

struct MainTabView: View {
    @StateObject private var store = ExpenseStore()

    var body: some View {
        TabView {
            ContentView(store: store)
                .tabItem { Label("Home", systemImage: "house.fill") }

            HistoryView(store: store)
                .tabItem { Label("History", systemImage: "list.bullet") }

            StatsView(store: store)
                .tabItem { Label("Stats", systemImage: "chart.pie.fill") }

            ProfileView(store: store)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
