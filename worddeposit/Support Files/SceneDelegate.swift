//
//  SceneDelegate.swift
//  worddeposit
//
//  Created by Maksim Kalik on 6/8/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var coordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let navigationController = UINavigationController()
        coordinator = AppCoordinator(navigationController: navigationController)
        coordinator?.start()

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.tintColor = Colors.dark
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

