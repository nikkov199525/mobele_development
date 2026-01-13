//
//  CartManager.swift
//  loginApp
//
//  Created by Дмитрий Васильев on 19.12.2025.
//

import Foundation

// MARK: - Cart Manager (Singleton)
/// Менеджер корзины - управляет товарами в корзине пользователя
class CartManager {
    static let shared = CartManager()
    private init() {}

    // MARK: - Properties
    var cartItems: [GoodsModel] = []

    // MARK: - Public Methods

    /// Добавить товар в корзину (или увеличить количество если уже есть)
    func addToCart(_ item: GoodsModel) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index].quantity += 1
        } else {
            var newItem = item
            newItem.quantity = 1
            cartItems.append(newItem)
        }
    }

    /// Удалить товар из корзины по индексу
    func removeFromCart(at index: Int) {
        guard index < cartItems.count else { return }
        cartItems.remove(at: index)
    }

    /// Получить общую стоимость всех товаров в корзине
    func getTotalPrice() -> Double {
        return cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    /// Очистить корзину
    func clearCart() {
        cartItems.removeAll()
    }

    /// Получить количество товаров в корзине
    func getItemsCount() -> Int {
        return cartItems.reduce(0) { $0 + $1.quantity }
    }
}
