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
    
    private(set) var childCoordinators = [Coordinator]()
    private(set) var navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    weak var delegate: MainCoordinatorDelegate?
    
    init(navigationController: UINavigationController ) {
        self.navigationController = navigationController
    }

    deinit {
        print("dealloc \(self)")
    }
    
    func start() {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(identifier: Storyboards.Home) as? BaseTabBarController else { return }
        tabBarController.coordinator = self
        navigationController.navigationBar.isHidden = true
        navigationController.setViewControllers([tabBarController], animated: false)
    }
}

// MARK: - didLogout called by MainViewModel
extension MainCoordinator {
    func didLogout() {
        parentCoordinator?.childDidFinish(self)
        delegate?.coordinatorDidLogout(coordinator: self)
        
        // TODO: - maybe temporary solution
        navigationController.dismiss(animated: true, completion: nil)
    }
}
