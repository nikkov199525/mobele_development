import Foundation
import Combine
import GRDB

enum ProductCode {
    static func makeNumericCode(fromId id: Int64, width: Int = 8) -> String {
        String(format: "%0*d", width, id)
    }
}

enum OrderStatus: String, CaseIterable, Identifiable {
    case new, processing, ready, completed, cancelled
    var id: String { rawValue }

    var title: String {
        switch self {
        case .new: return "Создан"
        case .processing: return "В обработке"
        case .ready: return "Готов"
        case .completed: return "Выполнен"
        case .cancelled: return "Отменён"
        }
    }
}

struct User: FetchableRecord, PersistableRecord {
    static let databaseTableName = "users"

    var id: Int64?
    var email: String
    var passwordHash: String
    var isu: String?

    init(id: Int64?, email: String, passwordHash: String, isu: String?) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.isu = isu
    }

    init(row: Row) {
        id = row["id"]
        email = row["email"]
        passwordHash = row["password_hash"]
        isu = row["isu"]
    }

    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["email"] = email
        container["password_hash"] = passwordHash
        container["isu"] = isu
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

struct Product: FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "products"

    var id: Int64?
    var code: String?
    var title: String
    var details: String
    var price: Double
    var category: String
    var inStock: Bool

    init(id: Int64?, code: String?, title: String, details: String, price: Double, category: String, inStock: Bool) {
        self.id = id
        self.code = code
        self.title = title
        self.details = details
        self.price = price
        self.category = category
        self.inStock = inStock
    }

    init(row: Row) {
        id = row["id"]
        code = row["code"]
        title = row["title"]
        details = row["details"]
        price = row["price"]
        category = row["category"]
        inStock = row["in_stock"]
    }

    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["code"] = code
        container["title"] = title
        container["details"] = details
        container["price"] = price
        container["category"] = category
        container["in_stock"] = inStock
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    enum Columns {
        static let id = Column("id")
        static let code = Column("code")
        static let title = Column("title")
        static let details = Column("details")
        static let price = Column("price")
        static let category = Column("category")
        static let inStock = Column("in_stock")
    }
}

struct CartItem: FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "cart_items"

    var id: Int64?
    var userId: Int64
    var productId: Int64
    var quantity: Int

    init(id: Int64?, userId: Int64, productId: Int64, quantity: Int) {
        self.id = id
        self.userId = userId
        self.productId = productId
        self.quantity = quantity
    }

    init(row: Row) {
        id = row["id"]
        userId = row["user_id"]
        productId = row["product_id"]
        quantity = row["quantity"]
    }

    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["user_id"] = userId
        container["product_id"] = productId
        container["quantity"] = quantity
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    enum Columns {
        static let id = Column("id")
        static let userId = Column("user_id")
        static let productId = Column("product_id")
        static let quantity = Column("quantity")
    }
}

struct CartLine: FetchableRecord, Decodable, Identifiable {
    var id: Int64
    var productId: Int64
    var title: String
    var price: Double
    var quantity: Int
}

struct Order: FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "orders"

    var id: Int64?
    var userId: Int64
    var createdAt: Date
    var status: String
    var customerName: String
    var contact: String
    var address: String
    var total: Double

    init(id: Int64?, userId: Int64, createdAt: Date, status: String, customerName: String, contact: String, address: String, total: Double) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.status = status
        self.customerName = customerName
        self.contact = contact
        self.address = address
        self.total = total
    }

    init(row: Row) {
        id = row["id"]
        userId = row["user_id"]
        createdAt = row["created_at"]
        status = row["status"]
        customerName = row["customer_name"]
        contact = row["contact"]
        address = row["address"]
        total = row["total"]
    }

    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["user_id"] = userId
        container["created_at"] = createdAt
        container["status"] = status
        container["customer_name"] = customerName
        container["contact"] = contact
        container["address"] = address
        container["total"] = total
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

struct OrderItem: FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "order_items"

    var id: Int64?
    var orderId: Int64
    var productId: Int64
    var titleSnapshot: String
    var priceSnapshot: Double
    var quantity: Int

    init(id: Int64?, orderId: Int64, productId: Int64, titleSnapshot: String, priceSnapshot: Double, quantity: Int) {
        self.id = id
        self.orderId = orderId
        self.productId = productId
        self.titleSnapshot = titleSnapshot
        self.priceSnapshot = priceSnapshot
        self.quantity = quantity
    }

    init(row: Row) {
        id = row["id"]
        orderId = row["order_id"]
        productId = row["product_id"]
        titleSnapshot = row["title_snapshot"]
        priceSnapshot = row["price_snapshot"]
        quantity = row["quantity"]
    }

    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["order_id"] = orderId
        container["product_id"] = productId
        container["title_snapshot"] = titleSnapshot
        container["price_snapshot"] = priceSnapshot
        container["quantity"] = quantity
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
