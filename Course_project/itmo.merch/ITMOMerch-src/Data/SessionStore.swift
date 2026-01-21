import Foundation
import Combine

final class SessionStore: ObservableObject {
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var currentUserId: Int64? = nil
    @Published private(set) var currentUserEmail: String? = nil

    private let keyUserId = "session.userId"
    private let keyEmail = "session.email"

    init() {
        let uid = UserDefaults.standard.object(forKey: keyUserId) as? Int64
        let em = UserDefaults.standard.string(forKey: keyEmail)
        if let uid, let em {
            self.currentUserId = uid
            self.currentUserEmail = em
            self.isAuthorized = true
        }
    }

    func signIn(userId: Int64, email: String) {
        UserDefaults.standard.set(userId, forKey: keyUserId)
        UserDefaults.standard.set(email, forKey: keyEmail)
        currentUserId = userId
        currentUserEmail = email
        isAuthorized = true
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: keyUserId)
        UserDefaults.standard.removeObject(forKey: keyEmail)
        currentUserId = nil
        currentUserEmail = nil
        isAuthorized = false
    }
}

enum Hashing {
    static func hash(_ s: String) -> String { String(s.reversed()) }
}
