//import FluentSQLite
import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
//    try services.register(FluentSQLiteProvider())
	try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
//    let sqlite = try SQLiteDatabase(storage: .memory)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
	let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "vapor", database: "vapor", password: "password", transport: .cleartext)
	let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)

	func vaporCloudConfig() {
		var databases = DatabasesConfig()
		let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
		let username = Environment.get("DATABASE_USER") ?? "vapor"
		let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
		let password = Environment.get("DATABSE_PASSWORD") ?? "password"
		
		let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: 5432, username: username, database: databaseName, password: password, transport: .cleartext)
		let database = PostgreSQLDatabase(config: databaseConfig)
		databases.add(database: database, as: .psql)
		services.register(databases)
	}
	
    /// Configure migrations
    var migrations = MigrationConfig()
	migrations.add(model: Acronym.self, database: DatabaseIdentifier.init("psql"))
    services.register(migrations)

}
