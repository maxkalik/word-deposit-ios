//
//  LoginViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

protocol LoginViewModelDelegate: AnyObject {
    func beginSignInProcess()
    func finishSignInSuccess()
    func finishSignInWithError(msg: String)
}

class LoginViewModel {
    
    weak var delegate: LoginViewModelDelegate?
    
    var illustrationImageName: String {
        return "some image"
    }
    
    var titleLabelText: String {
        return "Login"
    }
    
    var emailTexfieldPlacehoder: String {
        return "Email"
    }
    
    var passwordTextfieldPlaceholder: String {
        return "Password"
    }
    
    var loginButtonTitle: String {
        return "Log In"
    }
    
    var createAccountButtonTitle: String {
        return "Create Account"
    }
    
    var forgotPasswordButtonTitle: String {
        return "Forgot Password"
    }
}

extension LoginViewModel {
    func onSignIn(email: String, password: String) {
        delegate?.beginSignInProcess()
        
        UserService.shared.signIn(withEmail: email, password: password) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.finishSignInWithError(msg: error.localizedDescription)
            } else {
                self.fetchCurrentUser()
            }
        }
    }
    
    private func fetchCurrentUser() {
        UserService.shared.fetchCurrentUser { [weak self] error, user in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.finishSignInWithError(msg: error.localizedDescription)
            } else {
                self.finishSignInProcess(with: user)
            }
        }
    }
    
    private func finishSignInProcess(with user: User?) {
        guard user != nil else {
            self.delegate?.finishSignInWithError(msg: "User was deleted or not exist. Please register new one")
            return
        }
        self.delegate?.finishSignInSuccess()
    }
}
