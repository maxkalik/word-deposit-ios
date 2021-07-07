//
//  LoginViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class LoginViewModel: AuthenticationDependency {
    
    weak var delegate: AuthenticationViewModelDelegate?
    
    var illustrationImageName: String {
        return "some image"
    }
    
    var title: String {
        return "Login"
    }
    
    var submitButtonTitle: String {
        return "Log In"
    }
    
    var secondaryButtonTitle: String {
        return "Create Account"
    }
    
    var tertiaryButtonTitle: String {
        return "Forgot Password"
    }
}

extension LoginViewModel {
    func onSubmit(email: String, password: String) {
        delegate?.authenticationBegan()
        
        UserService.shared.signIn(withEmail: email, password: password) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.authFinishWithError(error.localizedDescription)
            } else {
                self.fetchCurrentUser()
            }
        }
    }
    
    private func fetchCurrentUser() {
        UserService.shared.fetchCurrentUser { [weak self] error, user in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.authFinishWithError(error)
            } else {
                self.finishSignInProcess(with: user)
            }
        }
    }
    
    private func finishSignInProcess(with user: User?) {
        guard user != nil else {
            self.delegate?.authFinishWithError("User was deleted or not exist. Please register new one")
            return
        }
        self.delegate?.authFinishWithSuccess()
    }
}
