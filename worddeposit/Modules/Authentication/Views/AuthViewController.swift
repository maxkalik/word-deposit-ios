//
//  AuthenticationVC.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/7/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

final class AuthViewController: UIViewController {
    
    @IBOutlet weak var illustration: UIImageView!
    @IBOutlet weak var titleLabel: LoginTitle!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var submitButton: PrimaryButton!
    @IBOutlet weak var buttonLinkFirst: DefaultButton!
    @IBOutlet weak var buttonLinkSecond: DefaultButton!

    var viewModel: AuthViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
        setupUI()
    }
    
    deinit {
        print("deinit auth view controller")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        emailTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        viewModel?.textFieldDidChange(email: email, password: password)
    }
    
    @objc func keyboardWillShow() {
        
    }
    
    @objc func keyboardWillHide() {
        
    }
    
    private func setupUI() {
        setupContent()
        setupTextFields()
        setupButtons()
    }
    
    private func setupContent() {
        guard let viewModel = self.viewModel else { return }
        illustration.image = UIImage(named: viewModel.illustrationImageName)
        titleLabel.text = viewModel.title
    }
    
    private func setupTextFields() {
        emailTextField.placeholder = viewModel?.emailPlacehoder
        passwordTextField.placeholder = viewModel?.passwordPlaceholder
    }
    
    private func setupButtons() {
        submitButton.setTitle(viewModel?.submitButtonTitle, for: .normal)
        buttonLinkFirst.setTitle(viewModel?.buttonLinkFirstTitle, for: .normal)

        if viewModel?.buttonLinkSecondTitle != nil {
            buttonLinkSecond.setTitle(viewModel?.buttonLinkSecondTitle, for: .normal)
        } else {
            buttonLinkSecond.removeFromSuperview()
        }
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        viewModel?.onSubmit()
    }

    @IBAction func buttonLinkFirstPressed(_ sender: UIButton) {
        viewModel?.onButtonLinkFirstPress()
    }

    @IBAction func buttonLinkSecondPressed(_ sender: UIButton) {
        viewModel?.onButtonLinkSecondPress()
    }
}

extension AuthViewController: AuthViewModelDelegate {
    func validEmail(isValid: Bool) {
        submitButton.isEnabled = isValid
    }
    
    func validPassword(isValid: Bool) {
        submitButton.isEnabled = isValid
    }
    
    func authProcessBegan() {
        
    }
    
    func authFinishWithError(_ msg: String) {
        
    }
    
    func authFinishWithError(_ err: Error) {
        
    }
    
    func authFinishWithSuccess() {
        
    }
}
