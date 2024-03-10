import Vapor
import FluentPostgresDriver

struct StatementResponse: Content {
    var saldo: StatementClient
    var ultimas_transacoes: [StatementTransaction]
}

struct StatementClient: Content {
    var total: Int
    var data_extrato: Date
    var limite: Int
}

struct StatementTransaction: Content {
    var valor: Int
    var tipo: String
    var descricao: String
    var realizada_em: Date
}

struct StatementController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("clientes", ":id", "extrato", use: getStatments)
    }
    
    
    func getStatments(req: Request) async throws -> StatementResponse {
        guard let clientId = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        guard let client = try await Client.query(on: req.db).filter(\.$clientId == clientId).first() else {
            throw Abort(.notFound)
        }
        
        let transactions = try await Transaction.query(on: req.db).filter(\.$clientId == clientId).sort(\.$createdAt, .descending).limit(10).all()
        
        let statementClient = StatementClient(total: client.amount, data_extrato: Date(), limite: client.limit)
        
        let statementTransactions = transactions.map { t in
            StatementTransaction(valor: t.value, tipo: t.type, descricao: t.description, realizada_em: t.createdAt.unsafelyUnwrapped)
        }
        
        return StatementResponse(saldo: statementClient, ultimas_transacoes: statementTransactions)
    }
}
