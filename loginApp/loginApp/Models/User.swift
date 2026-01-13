//
//  User.swift
//  loginApp
//
//  Created by Дмитрий Васильев on 19.12.2025.
//

import Foundation

// MARK: - User Model
/// Модель пользователя приложения
struct User {
    let id: String
    let login: String
    let password: String
    var name: String
    let avatar: String
    let email: String
    let phone: String
    let address: String
    let about: String
}

// MARK: - Mock Data
extension User {
    /// Мок-данные для тестового пользователя
    static func mockUser() -> User {
        return User(
            id: "user001",
            login: "1",
            password: "1",
            name: "Дмитрий",
            avatar: "person.circle.fill",
            email: "devasilyev@itmo.ru",
            phone: "+7 999 260-14-39",
            address: "Санкт-Петербург, Кронверкский проспект, д. 49а",
            about: "информация о пользователе"
        )
    }
}
