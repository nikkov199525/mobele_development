import Foundation

enum NGramSearch {

    static func normalize(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: "ё", with: "е")
            .filter { $0.isLetter || $0.isNumber || $0 == " " }
    }

    static func ngrams(of s: String, n: Int = 3) -> Set<String> {
        let chars = Array(s)
        guard chars.count >= n else { return [] }

        var result = Set<String>()
        for i in 0...(chars.count - n) {
            result.insert(String(chars[i..<i+n]))
        }
        return result
    }

    static func score(query: String, text: String) -> Int {
        let q = normalize(query)
        let t = normalize(text)

        let qGrams = ngrams(of: q)
        let tGrams = ngrams(of: t)

        return qGrams.intersection(tGrams).count
    }
}
