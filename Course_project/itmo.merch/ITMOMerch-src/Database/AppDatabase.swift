import Foundation
import Combine
import GRDB

final class AppDatabase: ObservableObject {
    static let shared = AppDatabase()

    private(set) var dbQueue: DatabaseQueue!

    private init() {}

    func bootstrap() throws {
        if dbQueue != nil { return }

        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
let dbURL = docs.appendingPathComponent("itmo_merch.sqlite")

try? fm.removeItem(at: dbURL)

        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA foreign_keys = ON;")
        }

        dbQueue = try DatabaseQueue(path: dbURL.path, configuration: config)

        try migrate()
        try seedIfNeeded()
    }

    private func migrate() throws {
        try Migrations.migrator.migrate(dbQueue)
    }

    private func seedIfNeeded() throws {
        try dbQueue.write { db in
            let count = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM products") ?? 0
            guard count == 0 else { return }

            let seed: [(title: String, details: String, price: Double, category: String, inStock: Bool)] = [
                ("Футболка «ИТМО: от абитуриента до ученого»", "Футболка, унисекс.", 1200, "Одежда", true),
                ("Худи ITMO", "Тёплое худи, унисекс.", 3990, "Одежда", true),
                ("Свитшот ITMO", "Свитшот, унисекс.", 2990, "Одежда", true),
                ("Кружка ITMO", "Керамика, 350 мл.", 990, "Аксессуары", true),
                ("Шоппер ITMO", "Тканевая сумка-шоппер.", 1290, "Аксессуары", true)
            ]

            for item in seed {
                var p = Product(
                    id: nil,
                    code: nil,
                    title: item.title,
                    details: item.details,
                    price: item.price,
                    category: item.category,
                    inStock: item.inStock
                )

                try p.insert(db)
                let newId = db.lastInsertedRowID

                p.id = newId
                p.code = ProductCode.makeNumericCode(fromId: newId, width: 8)
                try p.update(db)
            }
        }
    }
func resetDatabaseFiles() {
    do {
        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dbURL = docs.appendingPathComponent("itmo_merch.sqlite")
        try? fm.removeItem(at: dbURL)
    } catch { }
    dbQueue = nil
}
}
