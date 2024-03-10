import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    try app.register(collection: TransactionController())
    try app.register(collection: StatementController())
}
