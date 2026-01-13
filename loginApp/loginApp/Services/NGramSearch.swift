//
//  NGramSearch.swift
//  loginApp
//
//  Created by nikkov199525 on 13.01.2026.
//

import Foundation

enum NGramMode {
    case bigram
    case trigram
}

final class NGramSearch {

    private let mode: NGramMode

    init(mode: NGramMode = .trigram) {
        self.mode = mode
    }

    func score(query: String, text: String) -> Double {
        let q = normalize(query)
        let t = normalize(text)
        guard !q.isEmpty, !t.isEmpty else { return 0 }

        let qSet = ngrams(for: q)
        let tSet = ngrams(for: t)
        guard !qSet.isEmpty, !tSet.isEmpty else { return 0 }

        let intersection = qSet.intersection(tSet).count
        let union = qSet.union(tSet).count
        guard union > 0 else { return 0 }
        return Double(intersection) / Double(union)
    }

    func filter(query: String, items: [GoodsModel]) -> [GoodsModel] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }

        let scored: [(GoodsModel, Double)] = items.map { item in
            let text = "\(item.title) \(item.description)"
            return (item, score(query: trimmed, text: text))
        }

        return scored
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }

    // MARK: - Internals

    private func normalize(_ s: String) -> String {
        let lower = s.lowercased()
        let folded = lower.folding(options: .diacriticInsensitive, locale: .current)
        let allowed = folded.unicodeScalars.filter { scalar in
            CharacterSet.letters.contains(scalar) || CharacterSet.decimalDigits.contains(scalar) || scalar == " "
        }
        let cleaned = String(String.UnicodeScalarView(allowed))
        return cleaned
            .replacingOccurrences(of: " +", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func ngrams(for s: String) -> Set<String> {
        let n = (mode == .bigram) ? 2 : 3
        let padded = "  \(s)  "
        let chars = Array(padded)
        guard chars.count >= n else { return [] }

        var result: Set<String> = []
        result.reserveCapacity(chars.count)

        for i in 0...(chars.count - n) {
            let gram = String(chars[i..<(i + n)])
            result.insert(gram)
        }
        return result
    }
}
