import Foundation

struct User {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    var nativeLanguage: String
    
    init(
        id: String = "",
        email: String = "",
        firstName: String = "",
        lastName: String = "",
        nativeLanguage: String = ""
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.nativeLanguage = nativeLanguage
    }
    
    // dictionary -> object
    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        email = data["email"] as? String ?? ""
        firstName = data["firstname"] as? String ?? ""
        lastName = data["lastname"] as? String ?? ""
        nativeLanguage = data["native_language"] as? String ?? "English"
    }
    
    // converting to dictionary
    static func modelToData(user: User) -> [String: Any] {
        let data: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "firstname": user.firstName,
            "lastname": user.lastName,
            "native_language": user.nativeLanguage
        ]
        return data
    }
}
