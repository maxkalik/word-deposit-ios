//
//  AuthenticationVC.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/7/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

/*

BASE BIEW CONTROLLER
1. Spinner
2. Error alert
3. Notification?
4. Dismiss Keyboard

*/

import UIKit

final class AuthViewController: BaseViewController {
    
    @IBOutlet weak var illustration: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: AuthTextField!
    @IBOutlet weak var passwordTextField: AuthTextField!
    @IBOutlet weak var submitButton: PrimaryButton!
    @IBOutlet weak var buttonLinkFirst: BaseButton!
    @IBOutlet weak var buttonLinkSecond: BaseButton!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
    
    var viewModel: AuthViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
        viewModel?.dependency?.delegate = self
        setupUI()
        
        baseViewControllerDelegate = self
    }
    
    deinit {
        print("deinit auth view controller")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        viewModel?.authFieldsDidChange(email: email, password: password)
    }
    
    private func setupUI() {
        setupIllustration()
        setupTitle()
        setupTextFields()
        setupButtons()
    }
    
    private func setupTitle() {
        titleLabel.text = viewModel?.title
        titleLabel.textColor = Colors.dark
        titleLabel.font = UIFont(name: Fonts.medium, size: 22)
    }
    
    private func setupIllustration() {
        guard let illustrationImageName = self.viewModel?.illustrationImageName else {
            illustration.isHidden = true
            return
        }

        illustration.image = UIImage(named: illustrationImageName)
    }
    
    private func setupTextFields() {
        emailTextField.placeholder = viewModel?.emailPlacehoder
        if let passwordPlaceholder = viewModel?.passwordPlaceholder {
            passwordTextField.placeholder = passwordPlaceholder
        } else {
            passwordTextField.isHidden = true
        }
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

extension AuthViewController: AuthDelegate, AuthValidationDelegate {
    func validEmail(isValid: Bool) {
        submitButton.isEnabled = isValid
    }
    
    func validPassword(isValid: Bool) {
        submitButton.isEnabled = isValid
    }
    
    func authProcessBegan() {
        activityIndicator.show()
    }
    
    func authDidFinishWithError(_ msg: String) {
        activityIndicator.hide()
        showAlert(title: "Error", msg: msg)
    }
    
    func authDidFinishWithSuccess() {
        activityIndicator.hide()
    }
}

extension AuthViewController: BaseViewControllerDelegate {
    func keyboardDidShow() {
        print("keyboard did show")
    }
    
    func keyboardDidHide() {
        print("keyboard did hide")
    }
}
