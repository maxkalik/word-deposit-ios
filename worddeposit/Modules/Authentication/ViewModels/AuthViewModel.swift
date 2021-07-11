//
//  AuthenticationViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/7/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

protocol AuthViewModelDelegate: AnyObject {
    func validEmail(isValid: Bool)
    func validPassword(isValid: Bool)
    func authenticationBegan()
    func authFinishWithError(_ msg: String)
    func authFinishWithError(_ err: Error)
    func authFinishWithSuccess()
}

protocol AuthDependency {
    var coordinator: AuthCoordinator? { get }
    var illustrationImageName: String { get }
    var title: String { get }
    var submitButtonTitle: String { get }
    var buttonLinkFirstTitle: String { get }
    var buttonLinkSecondTitle: String? { get }

    func onSubmit(email: String, password: String)
    func onButtonLinkFirstPress()
    func onButtonLinkSecondPress()
}

extension AuthDependency {
    var buttonLinkSecondTitle: String? {
        get { return nil }
    }
}

class AuthViewModel {
    
    weak var delegate: AuthViewModelDelegate?
    var dependency: AuthDependency?
    
    var illustrationImageName: String {
        return dependency?.illustrationImageName ?? ""
    }
    
    var title: String {
        return dependency?.title ?? ""
    }
    
    var emailPlacehoder: String {
        return "Email"
    }
    
    var passwordPlaceholder: String {
        return "Password"
    }
    
    var submitButtonTitle: String {
        return dependency?.submitButtonTitle ?? ""
    }
    
    var buttonLinkFirstTitle: String {
        return dependency?.buttonLinkFirstTitle ?? ""
    }
    
    var buttonLinkSecondTitle: String? {
        return dependency?.buttonLinkSecondTitle
    }
    
    private func validateFields(email: String, password: String) {
        let validator = Validator()
        let isValidEmail = validator.validate(text: email, with: [.email, .notEmpty])
        let isValidPassword = validator.validate(text: password, with: [.password, .notEmpty])
        delegate?.validEmail(isValid: isValidEmail)
        delegate?.validPassword(isValid: isValidPassword)
    }
    
    func onSubmit(email: String, password: String) {
        dependency?.onSubmit(email: email, password: password)
    }
    
    func onButtonLinkFirstPress() {
        dependency?.onButtonLinkFirstPress()
    }
    
    func onButtonLinkSecondPress() {
        
    }
}
