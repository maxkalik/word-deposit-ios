//
//  MainCoordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.navigationController = UINavigationController()
        self.window = window
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let viewController = AuthenticationVC()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
//        let viewController = HomeViewController()
//        viewController.coordinator = self
//        navigationController.pushViewController(viewController, animated: true)
//        print("start")
    }
}
