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
        setupUI()
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
//        viewModel?.onSubmit(email: <#T##String#>, password: <#T##String#>)
    }

    @IBAction func buttonLinkFirstPressed(_ sender: UIButton) {
        viewModel?.onButtonLinkFirstPress()
    }

    @IBAction func buttonLinkSecondPressed(_ sender: UIButton) {
        
    }
}
