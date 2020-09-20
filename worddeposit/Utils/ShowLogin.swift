//
//  ShowLogin.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/19/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

func showLoginVC(view: UIView) {
   let storyboard = UIStoryboard(name: Storyboards.Main, bundle: nil)
   let loginVC = storyboard.instantiateViewController(identifier: Storyboards.Login)
    
    guard let window = view.window else {
        view.window?.rootViewController = loginVC
        view.window?.makeKeyAndVisible()
        return
    }
    
    window.rootViewController = loginVC
    window.makeKeyAndVisible()

    let options: UIView.AnimationOptions = .transitionCrossDissolve
    let duration: TimeInterval = 0.3
    
    UIView.transition(with: window, duration: duration, options: options, animations: nil, completion: nil)
}
