import SwiftUI
import GRDB

struct CartView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase

    @State private var lines: [CartLine] = []
    @State private var total: Double = 0

    var body: some View {
        List {
            if lines.isEmpty {
                EmptyStateView(title: "Корзина пуста", message: "Добавьте товары из каталога.")
            } else {
                ForEach(lines) { line in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(line.title)
                            Text("\(Int(line.price)) ₽")
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Stepper("\(line.quantity)", value: Binding(
                            get: { line.quantity },
                            set: { newValue in setQty(cartItemId: line.id, qty: newValue) }
                        ), in: 1...99)
                        .labelsHidden()
                        .accessibilityLabel("Количество")
                        .accessibilityValue("\(line.quantity)")
                        .accessibilityHint("Свайп вверх или вниз для изменения количества")
                    }
                    .accessibilityElement(children: .combine)
                }
                .onDelete(perform: delete)

                Section {
                    HStack {
                        Text("Итого")
                        Spacer()
                        Text("\(Int(total)) ₽").bold()
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Итого \(Int(total)) рублей")

                    NavigationLink {
                        CheckoutView()
                    } label: {
                        Text("Оформить заказ")
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityLabel("Оформить заказ")
                }
            }
        }
        .navigationTitle("Корзина")
        .onAppear { reload() }
    }

    private func reload() {
        guard let uid = session.currentUserId else { return }
        do {
            let res = try appDB.dbQueue.read { db -> ([CartLine], Double) in
                let lines = try CartRepo.lines(db: db, userId: uid)
                let total = try CartRepo.total(db: db, userId: uid)
                return (lines, total)
            }
            lines = res.0
            total = res.1
        } catch {
            lines = []
            total = 0
        }
    }

    private func setQty(cartItemId: Int64, qty: Int) {
        do {
            try appDB.dbQueue.write { db in
                try CartRepo.setQuantity(db: db, cartItemId: cartItemId, quantity: qty)
            }
            reload()
        } catch {}
    }

    private func delete(at offsets: IndexSet) {
        do {
            try appDB.dbQueue.write { db in
                for i in offsets {
                    try CartRepo.delete(db: db, cartItemId: lines[i].id)
                }
            }
            reload()
        } catch {}
    }
}
