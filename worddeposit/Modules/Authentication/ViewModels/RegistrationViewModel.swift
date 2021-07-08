//
//  RegistrationViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class RegistrationViewModel: AuthenticationDependency {
    
    weak var delegate: AuthenticationViewModelDelegate?
    
    var illustrationImageName: String {
        return "some image"
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
    
    var buttonLinkSecondTitle: String?
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
}
