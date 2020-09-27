//
//  TabBarConroller.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/28/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class TabBarConroller: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("tab bar controller called")
        tabBar.backgroundImage = .none
        tabBar.shadowImage = .none
        tabBar.backgroundColor = .clear
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        // Do any additional setup after loading the view.
        tabBar.tintColor = Colors.yellow
        tabBar.unselectedItemTintColor = Colors.dark
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tabBar.frame.size.height = 70
        tabBar.frame.origin.y = view.frame.height - 70
        
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
