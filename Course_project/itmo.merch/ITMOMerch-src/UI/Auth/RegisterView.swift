import SwiftUI
import GRDB

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorText: String? = nil

    var body: some View {
        Form {
            Section("Регистрация") {
                TextField("E-Mail", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Пароль", text: $password)

                if let errorText {
                    Text(errorText).foregroundStyle(.red)
                }

                Button("Создать аккаунт") { register() }
            }
        }
        .navigationTitle("Регистрация")
    }

    private func register() {
        errorText = nil

        let e = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let p = password

        guard e.contains("@"), e.contains(".") else {
            errorText = "Введите корректный e-mail."
            return
        }
        guard p.count >= 4 else {
            errorText = "Пароль слишком короткий."
            return
        }

        do {
            let user = try appDB.dbQueue.write { db in
                try AuthRepo.register(db: db, email: e, password: p)
            }
guard let uid = user.id, uid > 0 else {
    errorText = "Ошибка регистрации: не получен id пользователя."
    return
}
session.signIn(userId: uid, email: user.email)
dismiss()

        } catch {
            errorText = (error as NSError).localizedDescription
        }
    }
}
