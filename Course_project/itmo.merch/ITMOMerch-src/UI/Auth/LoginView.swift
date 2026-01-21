import SwiftUI
import GRDB

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase

    @State private var login: String = ""
    @State private var password: String = ""
    @State private var errorText: String? = nil
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Вход") {
                    TextField("E-Mail или номер ИСУ", text: $login)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    SecureField("Пароль", text: $password)

                    if let errorText {
                        Text(errorText).foregroundStyle(.red)
                    }

                    Button("Войти") { signIn() }
                }

                Section {
                    Button("Регистрация") { showRegister = true }
                }
            }
            .navigationTitle("ИТМО.Мерч")
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }

    private func signIn() {
        errorText = nil
        let l = login.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password

        guard !l.isEmpty, !p.isEmpty else {
            errorText = "Заполните логин и пароль."
            return
        }

        do {
            let user = try appDB.dbQueue.read { db in
                try AuthRepo.login(db: db, login: l, password: p)
            }
            session.signIn(userId: user.id ?? 0, email: user.email)
        } catch {
            errorText = (error as NSError).localizedDescription
        }
    }
}
