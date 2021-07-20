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
        self.title = "Add Word"
    }
}

class MainController: UITabBarController {
    
    var viewModel: MainViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCommon()
        setupTabBar()
        setupTopBarItem()
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = selectedViewController?.title
    }
    
    private func setupCommon() {
        view.backgroundColor = Colors.silver
    }
    
    private func setupTabBar() {
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        tabBar.tintColor = Colors.orange
        tabBar.unselectedItemTintColor = Colors.dark
    }
    
    private func setupTopBarItem() {
        let rightBarItem = TopBarItem()
        
        rightBarItem.setIcon(name: Icons.Profile)
        rightBarItem.circled()
        rightBarItem.onPress { [weak self] in
            guard let self = self else { return }
//            self.viewModel?.toProfile()
             self.viewModel?.logout()
        }
        let rightBarButtonItem = UIBarButtonItem(customView: rightBarItem)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
