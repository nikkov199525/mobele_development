import SwiftUI
import GRDB

struct CatalogView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase

    @State private var query: String = ""
    @State private var products: [Product] = []

    var body: some View {
        List {
            if products.isEmpty {
                EmptyStateView(title: "Нет товаров", message: "Добавь товары в seed")
            } else {
                ForEach(products) { p in
                    NavigationLink {
                        ProductDetailView(product: p)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(p.title).font(.headline)
                            Text("\(Int(p.price)) ₽")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let code = p.code, !code.isEmpty {
                                Text("Код: \(code)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        // VoiceOver: одна “карточка” на строку
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(accessibilityLabel(for: p))
                        .accessibilityHint("Двойной тап — открыть карточку товара")
                    }
                }
            }
        }
        .navigationTitle("Товары")
        .searchable(text: $query, prompt: "Поиск товаров")
        .onAppear { reload() }
        .onChange(of: query) { _ in reload() }
    }

    private func reload() {
        do {
            let q = query
            products = try appDB.dbQueue.read { db in
                try ProductsRepo.search(db: db, query: q)
            }
        } catch {
            products = []
        }
    }

    private func accessibilityLabel(for p: Product) -> String {
        var parts: [String] = [p.title, "\(Int(p.price)) рублей"]
        if let code = p.code, !code.isEmpty {
            parts.append("код товара \(code)")
        }
        return parts.joined(separator: ", ")
    }
}
