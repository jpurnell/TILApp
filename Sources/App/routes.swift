import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

	router.post("api", "acronyms") { req -> Future<Acronym> in
		return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
			return acronym.save(on: req)
		}
	}
	
//	router.post("api", "acronyms") {req -> Future<Acronym> in
//		return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
//			return acronym.save(on: req)
//		}
//	}
	
//	router.get("api", "acronyms") { req -> Future<[Acronym]> in
//		return Acronym.query(on: req).all()
//	}
	
//	router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//		return try req.parameters.next(Acronym.self)
//	}
	
//	router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//		return try flatMap(to: Acronym.self,
//						   req.parameters.next(Acronym.self),
//						   req.content.decode(Acronym.self)) {
//							acronym, updatedAcronym in
//							acronym.short = updatedAcronym.short
//							acronym.long = updatedAcronym.long
//							return acronym.save(on: req)
//		}
//	}
	
//	router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
//		return try req.parameters.next(Acronym.self)
//			.delete(on: req)
//			.transform(to: HTTPStatus.noContent)
//	}
	
//	router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
//		guard let searchTerm = req.query[String.self, at: "term"]?.lowercased() else {
//			throw Abort(.badRequest)
//		}
//		return try Acronym.query(on: req).group(.or) { or in
//			try or.filter(\.short == searchTerm.lowercased())
//			try or.filter(\.long == searchTerm.lowercased())
//			}.all()
//	}
	
//	router.get("api", "acronyms", "first") { req -> Future<Acronym> in
//		return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
//			guard let acronym = acronym else {
//				throw Abort(.notFound)
//			}
//			return acronym
//		}
//	}
	
//	router.get("api", "acronyms","sorted") { req -> Future<[Acronym]> in
//		return try Acronym.query(on: req).sort(\.short, .ascending).all()
//	}
	
	let acronymsController = AcronymsController()
	try router.register(collection: acronymsController)
	
	router.get("api", "acronyms", use: acronymsController.getAllHandler)
	
	// Create a UsersController instance
	let usersController = UsersController()
	
	// Register the new controller instance with the router to hook up the routes
	try router.register(collection: usersController)
	
	// Create a CategoriesController instance
	let categoriesController = CategoriesController()
	
	//	Register the new instance with the router to hook up the routes
	try router.register(collection: categoriesController)
}
