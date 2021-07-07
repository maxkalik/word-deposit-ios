//
//  AuthenticationViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/7/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

protocol AuthenticationViewModelDelegate: AnyObject {
    func validEmail(isValid: Bool)
    func validPassword(isValid: Bool)
    
}

class AuthenticationViewModel {
    
    weak var delegate: AuthenticationViewModelDelegate?
    private var loginViewModel: LoginViewModel?
    
    
    
    private func validateFields(email: String, password: String) {
        let validator = Validator()
        let isValidEmail = validator.validate(text: email, with: [.email, .notEmpty])
        let isValidPassword = validator.validate(text: password, with: [.password, .notEmpty])
        delegate?.validEmail(isValid: isValidEmail)
        delegate?.validPassword(isValid: isValidPassword)
    }
}
