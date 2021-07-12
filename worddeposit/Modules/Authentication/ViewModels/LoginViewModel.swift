//
//  LoginViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

protocol LoginViewModelDelegate: AuthDelegate {}

class LoginViewModel: Authentication {
    
    weak var delegate: AuthDelegate?
    private(set) var type: AuthType = .login
    private(set) var coordinator: AuthCoordinator
    
    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    var illustrationImageName: String? {
        return "login"
    }
    
    var title: String {
        return "Login"
    }
    
    var passwordPlaceholder: String? {
        return "Password"
    }
    
    var submitButtonTitle: String {
        return "Log In"
    }
    
    var buttonLinkFirstTitle: String {
        return "Create Account"
    }
    
    var buttonLinkSecondTitle: String? {
        return "Forgot Password"
    }
}

extension LoginViewModel {
    
    func onSubmit(with authCredentials: AuthCredentials) {
        delegate?.authProcessBegan()

        guard let password = authCredentials.password else {
            delegate?.authDidFinishWithError("Password is wrong")
            return
        }
        
        UserService.shared.signIn(withEmail: authCredentials.email, password: password) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.authDidFinishWithError(error.message)
            } else {
                self.fetchCurrentUser()
            }
        }
    }
    
    private func fetchCurrentUser() {
        UserService.shared.fetchCurrentUser { [weak self] error, user in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.authDidFinishWithError(error.message)
            } else {
                self.finishSignInProcess(with: user)
            }
        }
    }
    
    private func finishSignInProcess(with user: User?) {
        guard user != nil else {
            self.delegate?.authDidFinishWithError("User was deleted or not exist. Please register new one")
            return
        }
        self.delegate?.authDidFinishWithSuccess()
    }
    
    func onButtonLinkFirstPress() {
        coordinator.toRegistration()
    }
    
    func onButtonLinkSecondPress() {
        coordinator.toForgotPassword()
    }
}
