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
        print("tab bar controller called")
        tabBar.backgroundImage = .none
        tabBar.shadowImage = .none
        tabBar.backgroundColor = .clear
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        // Do any additional setup after loading the view.
        tabBar.tintColor = Colors.orange
        tabBar.unselectedItemTintColor = Colors.dark
     
        tabBar.items!.first?.titlePositionAdjustment = UIOffset(horizontal: 10.0, vertical: -10);
        tabBar.items?[1].titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10);
        tabBar.items!.last?.titlePositionAdjustment = UIOffset(horizontal: -10.0, vertical: -10);
        
        // Appearence
        let tabBarItemApperance = UITabBarItem.appearance()
        tabBarItemApperance.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 16)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Fonts.bold, size: 16)!], for: .selected)
        
        
        layerGradient.colors = [UIColor.clear.cgColor, Colors.silverLight.cgColor]
        layerGradient.locations = [0, 0.1]
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tabBar.layer.insertSublayer(layerGradient, at: 0)
        
        let tabBar = UITabBar.appearance()
        tabBar.barTintColor = UIColor.clear
        tabBar.backgroundImage = UIImage()
        
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
