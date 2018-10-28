//
//  AcronymCategoryPivot.swift
//  App
//
//  Created by Justin Purnell on 10/28/18.
//

import Foundation
import FluentPostgreSQL

// Define a new object, AcronymCategoryPivot that conforms to PostgreSQLUUIDPivot.
// This is a helper protocol on top of Fluen't Pivot protocol
final class AcronymCategoryPivot: PostgreSQLUUIDPivot {
	
	// Define an ID for the model. THis is a UUID type, so you must import the Foundation module in the file
	var id: UUID?
	
	// Define the two properties to link to the IDs of Acronym and Category. This is what holds the relationship
	var acronymID: Acronym.ID
	var categoryID: Category.ID
	
	// Define the Left and Right types required by Pivot. This tells Fluent wha the two models in the relationship are.
	typealias Left = Acronym
	typealias Right = Category
	
	// Tell Fluent the key path of the two ID properties for each side of the relationship
	static let leftIDKey: LeftIDKey = \.acronymID
	static let rightIDKey: RightIDKey = \.categoryID
	
	init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
		self.acronymID = acronymID
		self.categoryID = categoryID
	}
}

// Conform to Migration so Fluent can set up the table
extension AcronymCategoryPivot: Migration{
	// Implement prepare(on:) as defined by Migration. This overrides the default implementation
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
		
		// Create the table for AcronymCategoryPivot
		return Database.create(self, on: connection) { builder in
			// Use addProperties(to:) to add all the fields to the database
			try addProperties(to: builder)
			// Add a reference between the acronymID property on AcronymCategoryPivot and the id property on Acronym. This sets up a foreign key constraint
			try builder.reference(from: \.acronymID, to: \Acronym.id)
			// Add a reference between the categoryID property on AcronymCategoryPivot and the id property on Category. This sets up the foreign key constraint
			try builder.reference(from: \.categoryID, to: \Category.id)
		}
	}
}
