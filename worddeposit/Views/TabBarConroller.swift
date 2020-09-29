//
//  TabBarConroller.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/28/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class TabBarConroller: UITabBarController {

    let layerGradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = UIColor.clear
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        tabBar.tintColor = Colors.orange
        tabBar.unselectedItemTintColor = Colors.dark
     
        tabBar.items!.first?.titlePositionAdjustment = UIOffset(horizontal: 10.0, vertical: -10);
        tabBar.items?[1].titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10);
        tabBar.items!.last?.titlePositionAdjustment = UIOffset(horizontal: -10.0, vertical: -10);
        
        // Appearence
        let tabBarItemApperance = UITabBarItem.appearance()
        tabBarItemApperance.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 14)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 14)!], for: .selected)
        
        
        layerGradient.colors = [
            Colors.silver.withAlphaComponent(0).cgColor,
            Colors.silver.withAlphaComponent(0.7).cgColor,
            Colors.silver.withAlphaComponent(1).cgColor
        ]
        layerGradient.locations = [0, 0.03, 0.1]
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tabBar.layer.insertSublayer(layerGradient, at: 0)
        
        let appearance = UITabBar.appearance()
        appearance.barTintColor = UIColor.clear
        appearance.backgroundImage = UIImage()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = 70 + view.safeAreaInsets.bottom
        tabBar.frame.size.height = height
        tabBar.frame.origin.y = view.frame.height - height
        tabBar.invalidateIntrinsicContentSize()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
