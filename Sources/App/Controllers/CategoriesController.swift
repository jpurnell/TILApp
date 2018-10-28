//
//  CategoriesController.swift
//  App
//
//  Created by Justin Purnell on 10/28/18.
//

import Foundation
import Vapor

// Define a new CategoriesController type that conforms to RouteCollection
struct CategoriesController: RouteCollection {
	// Implement boot(router:) as required by RouteCollection. This is where you register route handlers
	func boot(router: Router) throws {
		// Create a route group for the path /api/categories
		let categoriesRoute = router.grouped("api", "categories")
		// Register the route handlers to their routes
		categoriesRoute.post(Category.self, use: createHandler)
		categoriesRoute.get(use: getAllHandler)
		categoriesRoute.get(Category.parameter, use: getHandler)
		categoriesRoute.get(Category.parameter, "acronyms", use: getAcronymsHandler)
	}
	
	// Define createHandler(_: category:) that will create a category
	func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
		return category.save(on: req)
	}
	
	
	//Define getAllHandler(_:) that returns all the categories
	func getAllHandler(_ req: Request) throws -> Future<[Category]> {
		// Perform a Fluent query to retrieve all the categories from the database
		return Category.query(on: req).all()
	}
	
	// Define getHandler(_:) that returns a single category
	func getHandler(_ req: Request) throws -> Future<Category>  {
		// Return the category extracted from the request's parameters
		return try req.parameters.next(Category.self)
	}
	
	// Define a new route handler, getAcronymsHandler(_:), that returns Future<[Acronym]>
	func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
		// Extract the category from the request's parameters and unwrap the returned future
		return try req.parameters.next(Category.self).flatMap(to: [Acronym].self) { category in
			// Use the new computed property to get the acronyms. Then use a Fluent query to return all the acronyms
			try category.acronyms.query(on: req).all()
		}
	}
}
