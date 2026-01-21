import SwiftUI

struct MainTabsView: View {
    var body: some View {
        TabView {
            NavigationStack {
                CatalogView()
            }
            .tabItem { Label("Товары", systemImage: "bag") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Профиль", systemImage: "person") }
        }
    }
}
