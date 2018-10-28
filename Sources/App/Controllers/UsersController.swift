//
//  UsersController.swift
//  App
//
//  Created by Justin Purnell on 10/27/18.
//

import Foundation
import Vapor

struct UsersController: RouteCollection {
	// Implement boot as required by RouteCollection
	
	func boot(router: Router) throws {
		// Create a new route group for the path /api/users
		let usersRoute = router.grouped("api", "users")
		usersRoute.post(User.self, use: createHandler)
		// Register getAllHandler(_:) to process GET requests to /api/users
		usersRoute.get(use: getAllHandler)
		// Register getHandler(_:) to process GET requests to /api/users/<USER ID>
		usersRoute.get(User.parameter, use: getHandler)
		// Register the acronyms handler
		usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
	}
	
	// Define the route handler function
	func createHandler(_ req: Request, user: User) throws -> Future<User> {
		
		// Save the decoded user from the request
		return user.save(on: req)
	}
	
	// Define a new route handler, getAllHandler(_:) the returns an array of Users in the future
	func getAllHandler(_ req: Request) throws -> Future<[User]> {
		// return all the users using a Fluent query
		return User.query(on: req).all()
	}
	
	// Define a new route handler, getHandler(_:) that returns a Future<User>
	func getHandler(_ req: Request) throws -> Future<User> {
		// Return the user specified by the request's parameter
		return try req.parameters.next(User.self)
	}
	
	// Define a new route handler, getAcronymsHandler(_:) that returns a Future<[Acronym]>
	func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
		// Fetch the user specified in the request's parameters and unwrap the returned future
		return try req.parameters.next(User.self).flatMap(to: [Acronym].self) { user in
			// Use the new computed property created above to get the acronyms using a Fluent query to return all the acronyms
			try user.acronyms.query(on: req).all()
		}
	}
}
