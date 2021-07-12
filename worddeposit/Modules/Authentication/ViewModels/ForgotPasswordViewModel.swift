//
//  ForgotPasswordViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/11/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class ForgotPasswordViewModel: Authentication {
    
    weak var delegate: AuthDelegate?
    private(set) var type: AuthType = .forgotPassword
    private(set) var coordinator: AuthCoordinator

    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }
    
    deinit {
        print("deinit \(self)")
    }

    var title: String {
        return "Forgot Password"
    }
    
    var submitButtonTitle: String {
        return "Reset Password"
    }
    
    var buttonLinkFirstTitle: String {
        return "Cancel"
    }
}

extension ForgotPasswordViewModel {
    func onSubmit(with authCredentials: AuthCredentials) {
        delegate?.authProcessBegan()
        UserService.shared.resetPassword(withEmail: authCredentials.email) { error in
            if let error = error {
                self.delegate?.authDidFinishWithError(error.message)
                return
            }
            self.delegate?.authDidFinishWithSuccess()
            self.coordinator.backToLogin()
        }
    }
    
    func onButtonLinkFirstPress() {
        coordinator.backToLogin()
    }
}
