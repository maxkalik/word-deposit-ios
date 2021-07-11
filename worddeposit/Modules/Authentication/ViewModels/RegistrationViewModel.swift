//
//  RegistrationViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class RegistrationViewModel: AuthDependency {
    
    var coordinator: AuthCoordinator?
    weak var delegate: AuthViewModelDelegate?
    
    var illustrationImageName: String {
        return "signup"
    }
    
    var title: String {
        return "Registration"
    }
    
    var submitButtonTitle: String {
        return "Sign Up"
    }
    
    var buttonLinkFirstTitle: String {
        return "Do you have an account already?"
    }
}

extension RegistrationViewModel {
    func onSubmit(email: String, password: String) {
        delegate?.authenticationBegan()

        UserService.shared.signUp(withEmail: email, password: password) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.delegate?.authFinishWithError(error)
            } else {
                self.delegate?.authFinishWithSuccess()
            }
        }
    }
    
    func onButtonLinkFirstPress() {
        
    }
    
    func onButtonLinkSecondPress() {
        
    }
}
