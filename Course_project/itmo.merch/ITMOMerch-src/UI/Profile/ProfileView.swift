import SwiftUI
import GRDB

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase

    @State private var cartCountText: String = "0 шт."
    @State private var lastOrders: [Order] = []

    var body: some View {
        List {
            Section("Аккаунт") {
                Text(session.currentUserEmail ?? "Неизвестный пользователь")
                Button(role: .destructive) { session.signOut() } label: { Text("Выйти") }
            }

            Section("Корзина") {
                NavigationLink {
                    CartView()
                } label: {
                    HStack {
                        Text("Открыть корзину")
                        Spacer()
                        Text(cartCountText).foregroundStyle(.secondary)
                    }
                }
            }

            Section("Мои заказы") {
                if lastOrders.isEmpty {
                    Text("Заказов пока нет").foregroundStyle(.secondary)
                } else {
                    ForEach(lastOrders) { o in
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
                    NavigationLink { OrdersView() } label: { Text("Показать все") }
                }
            }
        }
        .navigationTitle("Профиль")
        .onAppear { reload() }
    }

    private func reload() {
        guard let uid = session.currentUserId else { return }
        do {
            let (count, orders) = try appDB.dbQueue.read { db -> (Int, [Order]) in
                let count = try Int.fetchOne(db, sql: "SELECT COALESCE(SUM(quantity),0) FROM cart_items WHERE user_id = ?", arguments: [uid]) ?? 0
                let orders = try OrdersRepo.list(db: db, userId: uid)
                return (count, Array(orders.prefix(3)))
            }
            cartCountText = "\(count) шт."
            lastOrders = orders
        } catch {
            cartCountText = "0 шт."
            lastOrders = []
        }
    }

    private func shortId(_ id: Int64) -> String {
        String(format: "%06d", id)
    }
}
