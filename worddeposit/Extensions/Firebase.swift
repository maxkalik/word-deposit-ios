//
//  Firebase.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/15/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import Firebase

class ErrorAlert {
    static func show(errorCode: AuthErrorCode, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: errorCode.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension Auth {
    func handleFireAuthError(_ error: Error, viewController: UIViewController) {
        if let code = AuthErrorCode(rawValue: error._code) {
            ErrorAlert.show(errorCode: code, viewController: viewController)
        }
    }
}

extension AuthErrorCode {
    var message: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account. Pick antoher email."
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again"
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Your password or email is incorrect."
        default:
            return "Sorry, something went wrong."
        }
    }
}

extension Firestore {
    func handleFirestoreError(_ error: Error, viewController: UIViewController) {
        if let code = AuthErrorCode(rawValue: error._code) {
            ErrorAlert.show(errorCode: code, viewController: viewController)
        }
    }
}

extension FirestoreErrorCode {
    var message: String {
        switch self {
        case .notFound:
            return "There is no "
        default:
            return "Sorry, something went wrong.c"
        }
    }
}
