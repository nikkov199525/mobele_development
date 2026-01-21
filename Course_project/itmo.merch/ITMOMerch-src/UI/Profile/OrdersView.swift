import SwiftUI
import GRDB

struct OrdersView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase

    @State private var orders: [Order] = []

    var body: some View {
        List {
            if orders.isEmpty {
                EmptyStateView(title: "Нет заказов", message: "Оформите первый заказ из корзины.")
            } else {
                ForEach(orders) { o in
                    NavigationLink {
                        OrderDetailView(orderId: o.id ?? 0)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Заказ \(shortId(o.id ?? 0))")
                            Text("\(OrderStatus(rawValue: o.status)?.title ?? "—") • \(Int(o.total)) ₽")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Мои заказы")
        .onAppear { reload() }
    }

    private func reload() {
        guard let uid = session.currentUserId else { return }
        do {
            orders = try appDB.dbQueue.read { db in
                try OrdersRepo.list(db: db, userId: uid)
            }
        } catch {
            orders = []
        }
    }

    private func shortId(_ id: Int64) -> String { String(format: "%06d", id) }
}
