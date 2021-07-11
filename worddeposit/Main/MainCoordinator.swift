//
//  MainCoordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/11/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

protocol MainCoordinatorDelegate: AnyObject {
    func coordinatorDidLogout(coordinator: MainCoordinator)
}

class MainCoordinator: Coordinator {
    weak var parentCoordinator: AppCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    weak var delegate: MainCoordinatorDelegate?
    
    init(navigationController: UINavigationController ) {
        self.navigationController = navigationController
    }

    deinit {
        print("dealloc \(self)")
    }
    
    func start() {
        let mainViewController = UIViewController()
        mainViewController.view.backgroundColor = .red
//        mainViewcotroller.viewModel = MainViewModel(coordinator: self)
        navigationController.setViewControllers([mainViewController], animated: false)
    }
}

// MARK: - didLogout called by MainViewModel
extension MainCoordinator {
    func didLogout() {
        parentCoordinator?.childDidFinish(self)
        delegate?.coordinatorDidLogout(coordinator: self)
    }
}
