import Fluent

final class Client: Model {
    static let schema = "client"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "client_id")
    var clientId: Int

    @Field(key: "amount")
    var amount: Int
    
    @Field(key: "limit")
    var limit: Int

    init() { }
}
