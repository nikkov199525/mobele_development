import SwiftUI
import GRDB
import UIKit

struct ProductDetailView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var appDB: AppDatabase
    
    let product: Product
    @State private var message: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(product.title)
                    .font(.title2)
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                
                Text("\(Int(product.price)) ₽")
                    .font(.title3)
                    .accessibilityLabel("Цена \(Int(product.price)) рублей")
                
                if let code = product.code, !code.isEmpty {
                    Text("Код товара: \(code)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Код товара \(code)")
                }
                
                Text(product.details)
                    .font(.body)
                
                Button {
                    addToCart()
                } label: {
                    Text("Добавить в корзину")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Добавить в корзину")
                .accessibilityHint("Добавляет один экземпляр товара")
                
                if let message {
                    Text(message)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(message)
                }
            }
            .padding()
        }
        .navigationTitle("Товар")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    
    
    
    private func addToCart() {
        message = nil
        
        guard let uid = session.currentUserId else {
            message = "Нет активной сессии."
            UIAccessibility.post(notification: .announcement, argument: message!)
            return
        }
        
        guard let pid = product.id else {
            message = "У товара отсутствует идентификатор."
            UIAccessibility.post(notification: .announcement, argument: message!)
            return
        }
        
        do {
            try appDB.dbQueue.write { db in
                guard let freshProduct = try Product
                    .filter(Product.Columns.id == pid)
                    .fetchOne(db) else {
                    throw NSError(
                        domain: "Cart",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Товар не найден в базе"]
                    )
                }
                
                try CartRepo.add(db: db, userId: uid, product: freshProduct)
            }
            
            message = "Добавлено в корзину."
            UIAccessibility.post(notification: .announcement, argument: message!)
            
        } catch {
            message = error.localizedDescription
            UIAccessibility.post(notification: .announcement, argument: message!)
        }
    }
}
