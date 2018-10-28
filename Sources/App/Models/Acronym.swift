import Vapor
//import FluentSQLite
import FluentPostgreSQL

final class Acronym: Codable {
	var id: Int?
	var short: String
	var long: String
	var userID: User.ID
	
	init(short: String, long: String, userID: User.ID) {
		self.short = short
		self.long = long
		self.userID = userID
	}
}

//extension Acronym: Model {
//	typealias Database = SQLiteDatabase
//	typealias ID = Int
//	public static var idKey: IDKey = \Acronym.id
//}

//extension Acronym: SQLiteModel {}
extension Acronym: PostgreSQLModel {}
//extension Acronym: Migration {}
extension Acronym: Content {}
extension Acronym: Parameter {}

extension Acronym {
	// Add a computed property to Acronym to get the user object of the acronym's owner.
	// This returns Fluent's generic Parent type
	var user: Parent<Acronym, User> {
		// Uses Fluent's parent(_:) function to retrieve the parent
		// This takes the key path of the user reference on the acronym
		return parent(\.userID)
	}
}

extension Acronym: Migration {
//
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
		return Database.create(self, on: connection) { builder in
			try addProperties(to: builder)
			try builder.reference(from: \.userID, to: \User.id)
		}
	}
}
