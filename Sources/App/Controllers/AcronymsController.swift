import Vapor
import Fluent

struct AcronymsController: RouteCollection {
	func boot(router: Router) throws {
		let acronymsRoutes = router.grouped("api", "acronyms")
		acronymsRoutes.get(use: getAllHandler)
		acronymsRoutes.post(Acronym.self, use: createHandler)
		acronymsRoutes.get(Acronym.parameter, use: getHandler)
		acronymsRoutes.put(Acronym.parameter, use: updateHandler)
		acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
		acronymsRoutes.get("search", use: searchHandler)
		acronymsRoutes.get("first", use: getFirstHandler)
		acronymsRoutes.get("sorted", use: sortedHandler)
		acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)
		acronymsRoutes.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandler)
		acronymsRoutes.get(Acronym.parameter, "categories", use: getCategoriesHandler)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
		return Acronym.query(on: req).all()
	}
	
//	func createHandler(_ req: Request) throws -> Future<Acronym> {
//		return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) {
//			acronym in
//			return acronym.save(on: req)
//		}
//	}
	
	func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
		return acronym.save(on: req)
	}
	
	func getHandler(_ req: Request) throws -> Future<Acronym> {
		return try req.parameters.next(Acronym.self)
	}
	
//	func updateHandler(_ req: Request) throws -> Future<Acronym> {
//		return try flatMap(to: Acronym.self,
//						   req.parameters.next(Acronym.self),
//						   req.content.decode(Acronym.self)) {
//							acronym, updatedAcronym in
//							acronym.short = updatedAcronym.short
//							acronym.long = updatedAcronym.long
//							return acronym.save(on: req)
//		}
//	}
	
	func updateHandler(_ req: Request) throws -> Future<Acronym> {
		return try flatMap(to: Acronym.self,
						   req.parameters.next(Acronym.self),
						   req.content.decode(Acronym.self)) { acronym, updatedAcronym in
				acronym.short = updatedAcronym.short
				acronym.long  = updatedAcronym.long
				acronym.userID = updatedAcronym.userID
				return acronym.save(on: req)
		}
	}
	 
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.noContent)
	}
	
	func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
		guard let searchTerm = req.query[String.self, at: "term"] else {
			throw Abort(.badRequest)
		}
		return try Acronym.query(on: req).group(.or) { or in
			try or.filter(\.short == searchTerm.lowercased())
			try or.filter(\.long == searchTerm.lowercased())
		}.all()
	}
	
	func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
		return Acronym.query(on: req).first().map(to: Acronym.self) {
			acronym in
			guard let acronym = acronym else {
				throw Abort(.notFound)
			}
			return acronym
		}
	}
	
	func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
		return try Acronym.query(on: req).sort(\.short, .ascending).all()
	}
	
	// Define a new route handler, getUserHandler(_:) that returns Future<User>
	func getUserHandler(_ req: Request) throws -> Future<User> {
		// Fetch the acronym specified in the request's parameters and unwrap the returned future
		return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acronym in
			// Use the new computed property created above to get the acronym's owner
			try acronym.user.get(on: req)
		}
	}
	
	// Define a new route handler, addCategoriesHandler(_:), that returns a Future<HTTPStatus>
	func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		// Use flatMap(to:_:_:) to extract both the acronym and category from the request's parameters
		return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)) { acronym, category in
			
			// Create a new AcronymCategoryPivot object. It uses requireID() on the models to ensure that the IDs have been set. This will throw an error if they have not been set
			let pivot = try AcronymCategoryPivot(acronym.requireID(), category.requireID())
			return pivot.save(on: req).transform(to: .created)
		}
	}
	
	// Define a route handler getCategoriesHandler(_:) returning Future<[Category]>
	func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
		
		// Extract the acronym from the request's parameters and unwrap the returned future
		return try req.parameters.next(Acronym.self).flatMap(to: [Category].self) { acronym in
			
			// Use the new computed property to get the categories. Then use a Fluent query to return all the categories
			try acronym.categories.query(on: req).all()
		}
	}
}
