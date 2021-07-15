//
//  AuthenticationCoordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/10/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func coordinatorDidFinishAuth(coordinator: AuthCoordinator)
}

class AuthCoordinator: Coordinator {
    
    private(set) var childCoordinators = [Coordinator]()
    private(set) var navigationController: BaseNavigationController
    weak var parentCoordinator: AppCoordinator?
    weak var delegate: AuthCoordinatorDelegate?
    
    init(navigationController: BaseNavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("deinit - auth coordinator")
    }
    
    func start() {
        let authViewController = AuthViewController()
        let authViewModel = AuthViewModel()
        authViewModel.dependency = LoginViewModel(coordinator: self)
        authViewController.viewModel = authViewModel

        // navigationController.pushViewController(authViewController, animated: true)
        navigationController.setViewControllers([authViewController], animated: false)
    }
    
    func toRegistration() {
        let authViewController = AuthViewController()
        let authViewModel = AuthViewModel()
        authViewModel.dependency = RegistrationViewModel(coordinator: self)
        authViewController.viewModel = authViewModel

        navigationController.pushViewController(authViewController, animated: true)
    }
    
    func toForgotPassword() {
        let authViewController = AuthViewController()
        let authViewModel = AuthViewModel()
        authViewModel.dependency = ForgotPasswordViewModel(coordinator: self)
        authViewController.viewModel = authViewModel
        
        navigationController.pushViewController(authViewController, animated: true)
    }
    
    func backToLogin() {
        navigationController.popViewController(animated: true)
    }
    
    func authDidFinish() {
        parentCoordinator?.childDidFinish(self)
        delegate?.coordinatorDidFinishAuth(coordinator: self)
    }
}
