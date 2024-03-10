import Fluent

final class Transaction: Model {
    static let schema = "transaction"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "transaction_id")
    var transactionId: Int

    @Field(key: "value")
    var value: Int
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "client_id")
    var clientId: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }
}
