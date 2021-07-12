//
//  AuthenticationViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/7/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

enum AuthType {
    case login, registration, forgotPassword
}

protocol AuthDelegate: AnyObject {
    func authProcessBegan()
    func authDidFinishWithError(_ msg: String)
    func authDidFinishWithSuccess()
}

protocol AuthValidationDelegate: AnyObject {
    func validEmail(isValid: Bool)
    func validPassword(isValid: Bool)
}

protocol Authentication {
    var type: AuthType { get }
    var delegate: AuthDelegate? { get set }
    var coordinator: AuthCoordinator { get }
    var illustrationImageName: String? { get }
    var title: String { get }
    var passwordPlaceholder: String? { get }
    var submitButtonTitle: String { get }
    var buttonLinkFirstTitle: String { get }
    var buttonLinkSecondTitle: String? { get }

    func onSubmit(with authCredentials: AuthCredentials)
    func onButtonLinkFirstPress()
    func onButtonLinkSecondPress()
}

extension Authentication {
    var illustrationImageName: String? { return nil }
    var passwordPlaceholder: String? { return nil }
    var buttonLinkSecondTitle: String? { return nil }
    
    func onButtonLinkSecondPress() {}
}

class AuthViewModel {
    private var authCredentials: AuthCredentials?
    private let validator = Validator()
    weak var delegate: AuthValidationDelegate?
    var dependency: Authentication?
    
    deinit {
        print("deinit \(self)")
    }

    var illustrationImageName: String? {
        return dependency?.illustrationImageName
    }
    
    var title: String {
        return dependency?.title ?? ""
    }
    
    var emailPlacehoder: String {
        return "Email"
    }
    
    var passwordPlaceholder: String? {
        return dependency?.passwordPlaceholder
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
    
    func authFieldsDidChange(email: String, password: String) {
        if validateFields(email: email, password: password) {
            self.authCredentials = AuthCredentials(email: email, password: password)
        }
    }
    
    private func validateFields(email: String, password: String) -> Bool {
        let isValidEmail = validate(email: email)
        let isValidPassword = validate(password: password)
        return isValidEmail && isValidPassword
    }
    
    private func validate(email: String) -> Bool {
        let isValidEmail = validator.validate(text: email, with: [.email, .notEmpty])
        delegate?.validEmail(isValid: isValidEmail)
        return isValidEmail
    }
    
    private func validate(password: String) -> Bool {
        if dependency?.type == .forgotPassword { return true }
        let isValidPassword = validator.validate(text: password, with: [.password, .notEmpty])
        delegate?.validPassword(isValid: isValidPassword)
        return isValidPassword
    }
    
    func onSubmit() {
        guard let authCredentials = self.authCredentials else { return }
        dependency?.onSubmit(with: authCredentials)
    }
    
    func onButtonLinkFirstPress() {
        dependency?.onButtonLinkFirstPress()
    }
    
    func onButtonLinkSecondPress() {
        dependency?.onButtonLinkSecondPress()
    }
}
