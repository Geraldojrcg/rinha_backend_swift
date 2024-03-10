import Vapor
import FluentPostgresDriver

struct CreateTransaction: Content {
    var valor: Int
    var tipo: String
    var descricao: String
}

extension CreateTransaction: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("valor", as: Int.self, is: .range(0...))
        validations.add(
            "tipo", as: String.self,
            is: .in("c", "d")
        )
        validations.add("descricao", as: String.self, is: .count(1...10) && .alphanumeric)
    }
}

actor TransactionActor {
    var amount: Int = 0
    var limit: Int = 0
    
    func setAmount(newAmount: Int) {
        amount = newAmount
    }
    
    func setLimit(newLimit: Int) {
        limit = newLimit
    }
}

struct TransactionResponse: Content {
    var saldo: Int
    var limite: Int
}

struct TransactionController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("clientes", ":id", "transacoes", use: insertTransaction)
    }
    
    func insertTransaction(req: Request) async throws -> TransactionResponse {
        guard let clientId = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        try CreateTransaction.validate(content: req)
        
        let dto = try req.content.decode(CreateTransaction.self)
        
        let actor = TransactionActor()
        
        try await req.db.transaction { database in
            let query = Client.query(on: database)
            
            if req.db is SQLDatabase {
                query.filter(\.$clientId == clientId)
                query.filter(.sql(raw: "1 = 1 FOR UPDATE"))
            }
            
            guard let client = try await query.first() else {
                throw Abort(.notFound)
            }
            
            if dto.tipo == "c" {
                client.amount = client.amount + dto.valor
            } else {
                if client.amount - dto.valor < -client.limit {
                    throw Abort(.unprocessableEntity)
                }
                client.amount = client.amount - dto.valor
            }
            
            try await client.save(on: database)
            
            let transaction = Transaction()
            transaction.clientId = client.clientId
            transaction.type = dto.tipo
            transaction.value = dto.valor
            transaction.description = dto.descricao
            
            try await transaction.save(on: database)
            
            await actor.setLimit(newLimit: client.limit)
            await actor.setAmount(newAmount: client.amount)
        }
        
        return await TransactionResponse(saldo: actor.amount, limite: actor.limit)
    }
}
