import SwiftUI

struct RootView: View {
    @StateObject private var session = SessionStore()
    @StateObject private var cart = CartStore()

    @State private var didBootstrap = false
    @State private var dbReady = false

    var body: some View {
        Group {
            if !dbReady {
                VStack(spacing: 12) {
                    ProgressView("Запуск…")
                        .accessibilityLabel("Запуск приложения")
                    Text("Подготовка базы данных")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Подготовка базы данных")
                }
                .padding()
            } else {
                if session.isAuthorized {
                    MainTabsView()
                        .environmentObject(session)
                        .environmentObject(cart)
                        .environmentObject(AppDatabase.shared)
                } else {
                    LoginView()
                        .environmentObject(session)
                        .environmentObject(AppDatabase.shared)
                }
            }
        }
        .task {
            guard !didBootstrap else { return }
            didBootstrap = true

            do {
                try AppDatabase.shared.bootstrap()
                dbReady = true
            } catch {
                // Если хочешь радикально: можно тут же снести БД и повторить.
                // Но хотя бы не крашимся молча.
                print("DB bootstrap error: \(error)")
                dbReady = false
            }
        }
    }
}
