//
//  MainController.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/14/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

class TabOneViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        self.title = "Tab 1"
    }
}

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
        self.delegate = self
        
        tabBar.backgroundColor = UIColor.clear
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        tabBar.tintColor = Colors.orange
        tabBar.unselectedItemTintColor = Colors.dark
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabOne = TabOneViewController()
        let tabOneBarItem = UITabBarItem(title: "Tab 1", image: UIImage(named: "icon_practice"), tag: 0)
        tabOne.tabBarItem = tabOneBarItem
        
        let tabTwo = TabTwoViewController()
        let tabTwoBarItem = UITabBarItem(title: "Tab 2", image: UIImage(named: "icon_plus"), tag: 1)
        tabTwo.tabBarItem = tabTwoBarItem
        
        self.viewControllers = [tabOne, tabTwo]
        
    }
}

extension MainController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected \(viewController.title!)")
    }
}
