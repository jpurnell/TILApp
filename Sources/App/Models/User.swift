//
//  User.swift
//  App
//
//  Created by Justin Purnell on 10/27/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
	var id: UUID?
	var name: String
	var username: String
	
	init(name: String, username: String) {
		self.name = name
		self.username = username
	}
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}
extension User {
	// Add a computed property to User to get a user's acronyms
	// This returns Fluent's generic Children type
	var acronyms: Children<User, Acronym> {
		// Uses Fluent's children(_:) function to retrieve the children
		//This take the key path of the user reference on the acronym
		return children(\.userID)
	}
}
