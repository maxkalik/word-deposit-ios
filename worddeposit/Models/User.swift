import Foundation

struct User {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    
    init(
        id: String = "",
        email: String = "",
        firstName: String = "",
        lastName: String = ""
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // dictionary -> object
    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        email = data["email"] as? String ?? ""
        firstName = data["firstname"] as? String ?? ""
        lastName = data["lastname"] as? String ?? ""
    }
    
    // converting to dictionary
    static func modelToData(user: User) -> [String: Any] {
        let data: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "firstname": user.firstName,
            "lastname": user.lastName
        ]
        return data
    }
}
