import Foundation
import GRDB

enum AuthRepo {
    static func register(db: Database, email: String, password: String) throws -> User {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let hash = Hashing.hash(password)

        let existing = try User
            .filter(Column("email") == normalized)
            .fetchOne(db)

        if existing != nil {
            throw NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Email уже зарегистрирован"])
        }

var u = User(id: nil, email: normalized, passwordHash: hash, isu: nil)
try u.insert(db)
u.id = db.lastInsertedRowID
return u

    }

    static func login(db: Database, login: String, password: String) throws -> User {
        let trimmed = login.trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = Hashing.hash(password)

        let isDigits = !trimmed.isEmpty && trimmed.allSatisfy { $0.isNumber }

        let user: User?
        if isDigits {
            user = try User.filter(Column("isu") == trimmed).fetchOne(db)
        } else {
            user = try User.filter(Column("email") == trimmed.lowercased()).fetchOne(db)
        }

        guard let u = user else {
            throw NSError(domain: "Auth", code: 2, userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"])
        }
        guard u.passwordHash == hash else {
            throw NSError(domain: "Auth", code: 3, userInfo: [NSLocalizedDescriptionKey: "Неверный пароль"])
        }
        return u
    }
}

enum ProductsRepo {
    static func fetchAll(db: Database) throws -> [Product] {
        try Product.order(Product.Columns.title.asc).fetchAll(db)
    }

    static func search(db: Database, query: String) throws -> [Product] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let all = try fetchAll(db: db)
        guard !q.isEmpty else { return all }

        return all
            .map { product in
                let text = "\(product.title) \(product.details)"
                let score = NGramSearch.score(query: q, text: text)
                return (product, score)
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}

enum CartRepo {
    static func lines(db: Database, userId: Int64) throws -> [CartLine] {
        let sql = """
        SELECT
          c.id AS id,
          c.product_id AS productId,
          p.title AS title,
          p.price AS price,
          c.quantity AS quantity
        FROM cart_items c
        JOIN products p ON p.id = c.product_id
        WHERE c.user_id = ?
        ORDER BY p.title ASC
        """
        return try CartLine.fetchAll(db, sql: sql, arguments: [userId])
    }

    static func add(db: Database, userId: Int64, product: Product) throws {
        guard let pid = product.id else { return }

        if var existing = try CartItem
            .filter(CartItem.Columns.userId == userId && CartItem.Columns.productId == pid)
            .fetchOne(db) {
            existing.quantity += 1
            try existing.update(db)
        } else {
            var item = CartItem(id: nil, userId: userId, productId: pid, quantity: 1)
            try item.insert(db)
        }
    }

    static func setQuantity(db: Database, cartItemId: Int64, quantity: Int) throws {
        let q = max(1, quantity)
        try db.execute(
            sql: "UPDATE cart_items SET quantity = ? WHERE id = ?",
            arguments: [q, cartItemId]
        )
    }

    static func delete(db: Database, cartItemId: Int64) throws {
        try db.execute(sql: "DELETE FROM cart_items WHERE id = ?", arguments: [cartItemId])
    }

    static func clear(db: Database, userId: Int64) throws {
        try db.execute(sql: "DELETE FROM cart_items WHERE user_id = ?", arguments: [userId])
    }

    static func total(db: Database, userId: Int64) throws -> Double {
        let sql = """
        SELECT COALESCE(SUM(p.price * c.quantity), 0)
        FROM cart_items c
        JOIN products p ON p.id = c.product_id
        WHERE c.user_id = ?
        """
        return try Double.fetchOne(db, sql: sql, arguments: [userId]) ?? 0
    }
}

enum OrdersRepo {
    static func list(db: Database, userId: Int64) throws -> [Order] {
        try Order
            .filter(Column("user_id") == userId)
            .order(Column("created_at").desc)
            .fetchAll(db)
    }

    static func items(db: Database, orderId: Int64) throws -> [OrderItem] {
        try OrderItem
            .filter(Column("order_id") == orderId)
            .fetchAll(db)
    }

    static func cancel(db: Database, orderId: Int64) throws {
        try db.execute(
            sql: "UPDATE orders SET status = ? WHERE id = ?",
            arguments: [OrderStatus.cancelled.rawValue, orderId]
        )
    }

    static func createFromCart(
        db: Database,
        userId: Int64,
        customerName: String,
        contact: String,
        address: String
    ) throws -> Int64 {
        let lines = try CartRepo.lines(db: db, userId: userId)
        guard !lines.isEmpty else {
            throw NSError(domain: "Orders", code: 10, userInfo: [NSLocalizedDescriptionKey: "Корзина пуста"])
        }

        let total = lines.reduce(0.0) { $0 + (Double($1.quantity) * $1.price) }

        var order = Order(
            id: nil,
            userId: userId,
            createdAt: Date(),
            status: OrderStatus.new.rawValue,
            customerName: customerName,
            contact: contact,
            address: address,
            total: total
        )
try order.insert(db)
let oid = db.lastInsertedRowID
order.id = oid


        for l in lines {
            var oi = OrderItem(
                id: nil,
                orderId: oid,
                productId: l.productId,
                titleSnapshot: l.title,
                priceSnapshot: l.price,
                quantity: l.quantity
            )
            try oi.insert(db)
        }

        try CartRepo.clear(db: db, userId: userId)
        return oid
    }

    static func repeatToCart(db: Database, userId: Int64, orderId: Int64) throws {
        let its = try items(db: db, orderId: orderId)
        for it in its {
            let product = try Product.filter(Product.Columns.id == it.productId).fetchOne(db)
            if let product {
                try CartRepo.add(db: db, userId: userId, product: product)
            }
        }
    }
}
