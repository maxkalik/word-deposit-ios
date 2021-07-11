//
//  MainCoordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit
import FirebaseAuth

final class AppCoordinator: Coordinator {
    
    private var navigationController: UINavigationController
    private(set) var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("dealloc \(self)")
    }
    
    func start() {
        if Auth.auth().currentUser != nil {
            startWithMain()
        } else {
            startWithAuth()

        }
    }
    
    private func startWithMain() {
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        mainCoordinator.parentCoordinator = self
//        mainCoordinator.delegate = self
        mainCoordinator.start()
        childCoordinators.append(mainCoordinator)
    }
    
    private func startWithAuth() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        authCoordinator.delegate = self
        authCoordinator.start()
        childCoordinators.append(authCoordinator)
    }
    
    func finish() {
//        print(window.rootViewController?.removeFromParent())
//        let vc = UIViewController()
//        vc.view.backgroundColor = .red
//        rootViewController.pushViewController(vc, animated: true)
//        childCoordinators.removeAll()
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

//// MARK: - UINavigationControllerDelegate
//extension AppCoordinator: UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//
//        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
//            return
//        }
//
//        if navigationController.viewControllers.contains(fromViewController) {
//            return
//        }
//
//        if let authViewController = fromViewController as? AuthViewController {
//            print("auth view controller did finish")
////            childDidFinish(loginViewController.viewModel?.coordinator)
//        }
//
//        if let mainViewController = fromViewController as? UITabBarController {
//            print("main view controller did finish")
//        }
//    }
//}


extension AppCoordinator: AuthCoordinatorDelegate {
    func coordinatorDidFinishAuth(coordinator: AuthCoordinator) {
        startWithMain()
    }
}
