//
//  LoginViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class LoginViewModel: AuthDependency {
    
    var coordinator: AuthCoordinator?
    weak var delegate: AuthViewModelDelegate?
    
    deinit {
        print("deinit \(self)")
    }
    
    var illustrationImageName: String {
        return "login"
    }
    
    var title: String {
        return "Login"
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
        
        UserService.shared.signIn(withEmail: authCredentials.email, password: authCredentials.password) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.authDidFinishWithError(error.localizedDescription)
            } else {
                self.fetchCurrentUser()
            }
        }
    }
    
    private func fetchCurrentUser() {
        UserService.shared.fetchCurrentUser { [weak self] error, user in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.authDidFinishWithError(error)
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
        coordinator?.toRegistration()
    }
    
    func onButtonLinkSecondPress() {
        coordinator?.authDidFinish()
    }
}
