import SwiftUI
import GRDB

struct CheckoutView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase

    @State private var name: String = ""
    @State private var contact: String = ""
    @State private var address: String = ""
    @State private var errorText: String? = nil

    @State private var createdOrderId: Int64? = nil

    var body: some View {
        Form {
            Section("Данные") {
                TextField("Имя", text: $name)
                TextField("Телефон или e-mail", text: $contact)
                TextField("Адрес", text: $address)
            }

            if let errorText {
                Section { Text(errorText).foregroundStyle(.red) }
            }

            Section {
                Button("Подтвердить заказ") { create() }
            }
        }
        .navigationTitle("Оформление")
        .navigationDestination(isPresented: Binding(
            get: { createdOrderId != nil },
            set: { if !$0 { createdOrderId = nil } }
        )) {
            OrderDetailView(orderId: createdOrderId ?? 0)
        }
    }

    private func create() {
        errorText = nil
        guard let uid = session.currentUserId else { errorText = "Нет сессии."; return }
        guard !name.isEmpty, !contact.isEmpty, !address.isEmpty else {
            errorText = "Заполните все поля."
            return
        }

        do {
            let oid = try appDB.dbQueue.write { db in
                try OrdersRepo.createFromCart(
                    db: db,
                    userId: uid,
                    customerName: name,
                    contact: contact,
                    address: address
                )
            }
            createdOrderId = oid
        } catch {
            errorText = (error as NSError).localizedDescription
        }
    }
}
