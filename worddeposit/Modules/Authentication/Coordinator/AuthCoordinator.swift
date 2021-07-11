//
//  AuthenticationCoordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/10/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class AuthCoordinator: Coordinator {
    
//    private(set) var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let authViewController = AuthViewController()
        let authViewModel = AuthViewModel()
        let loginViewModel = LoginViewModel()
        loginViewModel.coordinator = self
        authViewModel.dependency = loginViewModel
        authViewController.viewModel = authViewModel

        navigationController.pushViewController(authViewController, animated: true)
    }
    
    func toRegistration() {
        let authViewController = AuthViewController()
        let authViewModel = AuthViewModel()
        let registrationViewModel = RegistrationViewModel()
        registrationViewModel.coordinator = self
        authViewModel.dependency = registrationViewModel
        authViewController.viewModel = authViewModel

        navigationController.pushViewController(authViewController, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
    }
    
}
