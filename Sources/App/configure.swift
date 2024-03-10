import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    guard let connectionString = Environment.get("DATABASE_CONNECTION_STRING") else {
        throw Abort(.internalServerError, reason: "DATABASE_CONNECTION_STRING env is missing")
    }
    
    try app.databases.use(.postgres(url: connectionString, maxConnectionsPerEventLoop: 10), as: .psql)
    
    try routes(app)
}
