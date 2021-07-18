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
        self.delegate = self
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        tabBar.tintColor = Colors.orange
        tabBar.unselectedItemTintColor = Colors.dark

        view.backgroundColor = Colors.silver
        
        setupBarItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = selectedViewController?.title
    }
    
    func setupBarItem() {
        let rightBarItem = TopBarItem()
        
        rightBarItem.setIcon(name: Icons.Profile)
        rightBarItem.circled()
        rightBarItem.onPress { [weak self] in
            guard let self = self else { return }
            self.viewModel?.toProfile()
            // self.viewModel?.logout()
        }
        let rightBarButtonItem = UIBarButtonItem(customView: rightBarItem)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
