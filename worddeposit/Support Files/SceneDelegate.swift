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
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window!.windowScene = windowScene
        coordinator = AppCoordinator(window: window!)
        coordinator?.start()

//        guard let _ = (scene as? UIWindowScene) else { return }
//        guard let window = self.window else { return }
//        window.tintColor = Colors.dark
//
//        if Auth.auth().currentUser != nil {
//            let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
//            let tabBarController = storyboard.instantiateViewController(identifier: Storyboards.Home) as? UITabBarController
//            window.rootViewController = tabBarController
//        }
        
    }
}

