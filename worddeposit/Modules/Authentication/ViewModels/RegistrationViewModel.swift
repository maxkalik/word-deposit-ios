//
//  RegistrationViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class RegistrationViewModel: Authentication {
    
    private(set) var coordinator: AuthCoordinator
    private(set) var type: AuthType = .registration
    weak var delegate: AuthViewModelDelegate?

    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    var illustrationImageName: String? {
        return "signup"
    }
    
    var title: String {
        return "Registration"
    }
    
    var passwordPlaceholder: String? {
        return "Password"
    }
    
    var submitButtonTitle: String {
        return "Sign Up"
    }
    
    var buttonLinkFirstTitle: String {
        return "Do you have an account already?"
    }
}

extension RegistrationViewModel {
    
    func onSubmit(with authCredentials: AuthCredentials) {
        delegate?.authProcessBegan()
        
        guard let password = authCredentials.password else {
            delegate?.authDidFinishWithError("Password is wrong")
            return
        }

        UserService.shared.signUp(withEmail: authCredentials.email, password: password) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.authDidFinishWithError(error)
            } else {
                self.delegate?.authDidFinishWithSuccess()
                self.coordinator.authDidFinish()
            }
        }
    }
    
    func onButtonLinkFirstPress() {
        coordinator.backToLogin()
    }
}
