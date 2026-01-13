//
//  ImageLoader.swift
//  loginApp
//
//  Created by ChatGPT on 12.01.2026.
//

import UIKit

/// Простой загрузчик изображений с кэшем.
final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 200
    }

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Если это не URL, считаем что это SF Symbol (как в моках)
        guard trimmed.lowercased().hasPrefix("http") else {
            completion(UIImage(systemName: trimmed))
            return
        }

        if let cached = cache.object(forKey: trimmed as NSString) {
            completion(cached)
            return
        }

        guard let url = URL(string: trimmed) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20

        session.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil else {
                completion(nil)
                return
            }

            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                completion(nil)
                return
            }

            guard let data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            self?.cache.setObject(image, forKey: trimmed as NSString)
            completion(image)
        }.resume()
    }
}
