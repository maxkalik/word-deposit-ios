//
//  MainController.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/14/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class TabTwoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.title = "Tab 2"
    }
}

class MainController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.delegate = self
        
        tabBar.backgroundColor = UIColor.clear
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        tabBar.tintColor = Colors.orange
        tabBar.unselectedItemTintColor = Colors.dark
    }
}

extension MainController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("Selected \(viewController.title!)")
    }
}
