//
//  Product.swift
//  loginApp
//
//  Created by Дмитрий Васильев on 19.12.2025.
//

import Foundation

// MARK: - Product Model
/// Модель товара в магазине
struct GoodsModel: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let image: String
    var quantity: Int

    init(id: Int, title: String, price: Double, description: String, image: String, quantity: Int = 1) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.image = image
        self.quantity = quantity
    }
}

// MARK: - Mock Data
extension GoodsModel {
    /// Мок-данные для демонстрации работы приложения
    static func mockGoods() -> [GoodsModel] {
        return [
            GoodsModel(
                id: 1,
                title: "iPhone 15 Pro",
                price: 89990.0,
                description: "Смартфон Apple с процессором A17 Pro",
                image: "iphone.gen3"
            ),
            GoodsModel(
                id: 2,
                title: "MacBook Air M2",
                price: 119990.0,
                description: "Ноутбук Apple на чипе M2",
                image: "laptopcomputer"
            ),
            GoodsModel(
                id: 3,
                title: "AirPods Pro",
                price: 24990.0,
                description: "Беспроводные наушники с шумоподавлением",
                image: "airpodspro"
            ),
            GoodsModel(
                id: 4,
                title: "Apple Watch Series 9",
                price: 39990.0,
                description: "Умные часы с датчиком здоровья",
                image: "applewatch"
            ),
            GoodsModel(
                id: 5,
                title: "iPad Air",
                price: 69990.0,
                description: "Планшет с дисплеем Liquid Retina",
                image: "ipad.gen2"
            ),
            GoodsModel(
                id: 6,
                title: "Magic Keyboard",
                price: 9990.0,
                description: "Беспроводная клавиатура для Mac",
                image: "keyboard"
            )
        ]
    }
}
