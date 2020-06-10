import Foundation

struct User {
    var id: String
    var email: String
    
    // default initializer
    init(
        id: String = "",
        email: String = ""
    ) {
        self.id = id
        self.email = email
    }
    
    // dictionary -> object
    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        email = data["email"] as? String ?? ""
    }
    
    // converting to dictionary
    static func modelToData(user: User) -> [String: Any] {
        let data: [String: Any] = [
            "id": user.id,
            "email": user.email
        ]
        return data
    }
}
