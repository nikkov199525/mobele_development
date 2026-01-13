//
//  NetworkError.swift
//  loginApp
//
//  Created by nikkov199525 on 13.01.2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case transport(underlying: Error)
    case nonHTTPResponse
    case httpStatus(code: Int)
    case emptyData
    case decoding(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес запроса"
        case .transport(let underlying):
            return "Ошибка сети: \(underlying.localizedDescription)"
        case .nonHTTPResponse:
            return "Сервер не отвечает"
        case .httpStatus(let code):
            return "Ошибка сервера (HTTP \(code))."
        case .emptyData:
            return "Сервер не вернул никаких данных"
        case .decoding(let underlying):
            return "Не удалось обработать данные: \(underlying.localizedDescription)"
        }
    }
}
