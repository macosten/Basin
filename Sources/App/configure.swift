import Authentication
import FluentPostgreSQL
import FluentPostGIS
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    //PostGIS
    try services.register(FluentPostGISProvider())
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(SessionsMiddleware.self) // Enables sessions.
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let psql = try PostgreSQLDatabase(config: PostgreSQLDatabaseConfig.default())

    // Register the configured Postgres database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .psql)
    databases.add(database: psql, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: UserAccessToken.self, database: .psql)
    services.register(migrations)

}
