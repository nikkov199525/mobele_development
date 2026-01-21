import SwiftUI
import GRDB

struct OrderDetailView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase

    let orderId: Int64

    @State private var order: Order? = nil
    @State private var items: [OrderItem] = []

    var body: some View {
        List {
            if let order {
                Section("Статус") {
                    Text(OrderStatus(rawValue: order.status)?.title ?? "—")
                        .font(.headline)
                }

                Section("Состав") {
                    ForEach(items) { it in
                        HStack {
                            Text(it.titleSnapshot)
                            Spacer()
                            Text("\(it.quantity) × \(Int(it.priceSnapshot)) ₽")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Итого") {
                    HStack {
                        Text("Сумма")
                        Spacer()
                        Text("\(Int(order.total)) ₽").bold()
                    }
                }

                Section("Управление") {
                    let st = OrderStatus(rawValue: order.status) ?? .new
                    if st == .new || st == .processing {
                        Button(role: .destructive) { cancel() } label: { Text("Отменить заказ") }
                    }

                    Button { repeatOrder() } label: { Text("Повторить заказ") }
                }
            } else {
                EmptyStateView(title: "Загрузка", message: "Читаем заказ из базы…")
            }
        }
        .navigationTitle("Заказ \(String(format: "%06d", orderId))")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { reload() }
    }

    private func reload() {
        do {
            let res = try appDB.dbQueue.read { db -> (Order?, [OrderItem]) in
                let o = try Order.filter(Column("id") == orderId).fetchOne(db)
                let its = try OrdersRepo.items(db: db, orderId: orderId)
                return (o, its)
            }
            order = res.0
            items = res.1
        } catch {
            order = nil
            items = []
        }
    }

    private func cancel() {
        do {
            try appDB.dbQueue.write { db in
                try OrdersRepo.cancel(db: db, orderId: orderId)
            }
            reload()
        } catch {}
    }

    private func repeatOrder() {
        guard let uid = session.currentUserId else { return }
        do {
            try appDB.dbQueue.write { db in
                try OrdersRepo.repeatToCart(db: db, userId: uid, orderId: orderId)
            }
        } catch {}
    }
}
