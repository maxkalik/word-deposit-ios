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
    
    var viewModel: MainViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        tabBar.tintColor = Colors.orange
        tabBar.unselectedItemTintColor = Colors.dark

        view.backgroundColor = Colors.silver
        
        setupBarItem()
    }
    
    
    func setupBarItem() {
        let rightBarItem = TopBarItem()
        
        rightBarItem.setIcon(name: Icons.Profile)
        rightBarItem.circled()
        rightBarItem.onPress {
            self.viewModel?.logout()
        }
        let rightBarButtonItem = UIBarButtonItem(customView: rightBarItem)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}

extension MainController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("Selected \(viewController.title!)")
    }
}
