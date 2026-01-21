import SwiftUI

@main
struct ITMOMerchApp: App {
    @StateObject private var appDB = AppDatabase.shared
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appDB)
                .environmentObject(session)
        }
    }
}
