// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Conflux",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),

        // 👤 Authentication and Authorization layer for Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        
        // Swift PostGIS support for FluentPostgreSQL and Vapor.
        .package(url: "https://github.com/plarson/fluent-postgis.git", .branch("master"))
        
        //Todo: add Imperial for federated login.
        
    ],
    targets: [
        .target(name: "App", dependencies: ["Authentication", "FluentPostgreSQL", "Vapor", "FluentPostGIS"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

