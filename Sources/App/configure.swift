import Authentication
import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

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

    /// Configure migrations.
    //MARK -- Make sure that every single model that gets saved to the database has a migration.
    var migrations = MigrationConfig()
    //User Migrations
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: UserAccessToken.self, database: .psql)
    
    //Post and content migrations
    migrations.add(model: Post.self, database: .psql)
    migrations.add(model: PostComment.self, database: .psql)
    
    //Pivot migrations
    migrations.add(model: PostUserPivot.self, database: .psql)
    migrations.add(model: PostCommentUserPivot.self, database: .psql)
    
    services.register(migrations)


}
