import Foundation
import GRDB

enum Migrations {
    static var migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("create_v1") { db in
            try db.create(table: "users") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("email", .text).notNull().unique(onConflict: .abort)
                t.column("password_hash", .text).notNull()
                t.column("isu", .text)
            }

            try db.create(table: "products") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("code", .text).unique(onConflict: .abort)
                t.column("title", .text).notNull()
                t.column("details", .text).notNull()
                t.column("price", .double).notNull()
                t.column("category", .text).notNull()
                t.column("in_stock", .boolean).notNull()
            }

            try db.create(table: "cart_items") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull().indexed()
                    .references("users", onDelete: .cascade)
                t.column("product_id", .integer).notNull().indexed()
                    .references("products", onDelete: .cascade)
                t.column("quantity", .integer).notNull()
                t.uniqueKey(["user_id", "product_id"])
            }

            try db.create(table: "orders") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("user_id", .integer).notNull().indexed()
                    .references("users", onDelete: .cascade)
                t.column("created_at", .datetime).notNull()
                t.column("status", .text).notNull()

                t.column("customer_name", .text).notNull()
                t.column("contact", .text).notNull()
                t.column("address", .text).notNull()
                t.column("total", .double).notNull()
            }

            try db.create(table: "order_items") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("order_id", .integer).notNull().indexed()
                    .references("orders", onDelete: .cascade)
                t.column("product_id", .integer).notNull().indexed()
                    .references("products", onDelete: .restrict)

                t.column("title_snapshot", .text).notNull()
                t.column("price_snapshot", .double).notNull()
                t.column("quantity", .integer).notNull()
            }
        }

        return migrator
    }()
}
