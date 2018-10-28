//
//  Category.swift
//  App
//
//  Created by Justin Purnell on 10/28/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class Category: Codable {
	var id: Int?
	var name: String
	
	init(name: String) {
		self.name = name
	}
}

extension Category: PostgreSQLModel {}
extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}
extension Category {
// Add a computed property to category to get its acronyms. This returns Fluent's generic Sibling type. It returns the siblings of a Category that are of type Acronym and helf using the AcronymCategoryPivot
	var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
		// Use fluents siblings() function to retrieve all the acronyms
		return siblings()
	}
	
}
