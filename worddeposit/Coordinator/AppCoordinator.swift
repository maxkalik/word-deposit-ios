//
//  MainCoordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    private let window: UIWindow
    private var rootViewController = UINavigationController()
    private(set) var childCoordinators: [Coordinator] = []

    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let authCoordinator = AuthCoordinator(navigationController: rootViewController)
        authCoordinator.parentCoordinator = self
        childCoordinators.append(authCoordinator)

        authCoordinator.start()
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
