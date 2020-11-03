//
//  TabBarConroller.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/28/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class TabBarConroller: UITabBarController, UITabBarControllerDelegate {
    
    let layerGradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.backgroundColor = UIColor.clear
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        tabBar.tintColor = Colors.orange
        tabBar.unselectedItemTintColor = Colors.dark
     
        tabBar.items!.first?.titlePositionAdjustment = UIOffset(horizontal: 10.0, vertical: -5);
        tabBar.items?[1].titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5);
        tabBar.items!.last?.titlePositionAdjustment = UIOffset(horizontal: -10.0, vertical: -5);
        
        // Appearence
        let tabBarItemApperance = UITabBarItem.appearance()
        tabBarItemApperance.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 14)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 14)!], for: .selected)
        
        layerGradient.colors = [
            Colors.silver.withAlphaComponent(0).cgColor,
            Colors.silver.withAlphaComponent(0.7).cgColor,
            Colors.silver.withAlphaComponent(1).cgColor
        ]
        layerGradient.locations = [0, 0.025, 0.05]
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tabBar.layer.insertSublayer(layerGradient, at: 0)
        
        let appearance = UITabBar.appearance()
        appearance.barTintColor = UIColor.clear
        appearance.backgroundImage = UIImage()
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        // If your view controller is emedded in a UINavigationController you will need to check if it's a UINavigationController and check that the root view controller is your desired controller (or subclass the navigation controller)
        if viewController is AddWordVC {
            PresentVC.addWordVC(from: self)
            return false
        }

        // Tells the tab bar to select other view controller as normal
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = 90 + view.safeAreaInsets.bottom
        tabBar.frame.size.height = height
        tabBar.frame.origin.y = view.frame.height - height
        tabBar.invalidateIntrinsicContentSize()
    }
}
