import Foundation

class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidatorType {
    case email
    case password
    case name
    case title
    case word
    case requiredField(field: String)
}

enum ValidatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email: return EmailValidator()
        case .password: return PasswordValidator()
        case .name: return NameValidator()
        case .title: return TitleValidator()
        case .word: return WordValidator()
        case .requiredField(let fieldName): return RequiredFieldValidator(fieldName)
        }
    }
}

// MARK: - Validators

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(
                pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$",
                options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)
                ) == nil {
                throw ValidationError("Invalid e-mail Address")
            }
        } catch {
            throw ValidationError("Invalid e-mail Address")
        }
        return value
    }
}

struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("Password is Required")}
        guard value.count >= 6 else { throw ValidationError("Password must have at least 6 characters") }
        
        do {
            if try NSRegularExpression(pattern: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Password must be more than 6 characters, with at least one character and one numeric character")
            }
        } catch {
            throw ValidationError("Password must be more than 6 characters, with at least one character and one numeric character")
        }
        return value
    }
}

struct NameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 3 else { throw ValidationError("Name must contain more than three characters") }
        guard value.count < 18 else { throw ValidationError("Name shoudn't conain more than 18 characters") }
        
        do {
            if try NSRegularExpression(pattern: "^[a-z]{1,18}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid Name, username should not contain whitespaces, numbers or special characters")
            }
        } catch {
            throw ValidationError("Invalid Name, username should not contain whitespaces,  or special characters")
        }
        
        return value
    }
}

struct TitleValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 1 else { throw ValidationError("Title must contain more than one characters") }
        guard value.count < 26 else { throw ValidationError("Title shoudn't conain more than 26 characters") }
        return value
    }
}

struct WordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 1 else { throw ValidationError("Word must contain more than one characters") }
        guard value.count < 200 else { throw ValidationError("Word shoudn't conain more than 26 characters") }
        return value
    }
}

struct RequiredFieldValidator: ValidatorConvertible {
    private let fieldName: String
    
    init(_ field: String) {
        fieldName = field
    }
    
    func validated(_ value: String) throws -> String {
        guard value.isNotEmpty else {
            throw ValidationError("Required field " + fieldName)
        }
        return value
    }
}
