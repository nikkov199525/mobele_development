//
//  ProductsService.swift
//  loginApp
//
//  Created by nikkov199525 on 13.01.2026.
//

import Foundation

protocol ProductsServicing {
    func fetchProducts(completion: @escaping (Result<[GoodsModel], NetworkError>) -> Void)
}

final class ProductsService: ProductsServicing {

    private let session: URLSession
    private let endpoint: URL

    init(
        session: URLSession = .shared,
        endpoint: URL = URL(string: "https://api.escuelajs.co/api/v1/products")!
    ) {
        self.session = session
        self.endpoint = endpoint
    }

    func fetchProducts(completion: @escaping (Result<[GoodsModel], NetworkError>) -> Void) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(.transport(underlying: error)))
                return
            }

            guard let http = response as? HTTPURLResponse else {
                completion(.failure(.nonHTTPResponse))
                return
            }

            guard (200...299).contains(http.statusCode) else {
                completion(.failure(.httpStatus(code: http.statusCode)))
                return
            }

            guard let data, !data.isEmpty else {
                completion(.failure(.emptyData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let apiProducts = try decoder.decode([APIProduct].self, from: data)
                let mapped = apiProducts.map { $0.toGoodsModel() }
                completion(.success(mapped))
            } catch {
                completion(.failure(.decoding(underlying: error)))
            }
        }.resume()
    }
}

// MARK: - API DTO

private struct APIProduct: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let images: [String]?

    func toGoodsModel() -> GoodsModel {
        let firstImage = images?.first ?? ""
        return GoodsModel(
            id: id,
            title: title,
            price: price,
            description: description,
            image: firstImage,
            quantity: 1
        )
    }
}
