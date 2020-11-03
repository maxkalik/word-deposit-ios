//
//  ShowLogin.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/19/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class PresentVC {
    
    // MARK: - Login VC
    static func loginVC(from view: UIView) {
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
    
    // MARK: - Add Word VC
    static func addWordVC(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
        if let addWordVC = storyboard.instantiateViewController(withIdentifier: Storyboards.AddWordVC) as? AddWordVC {
            addWordVC.modalPresentationStyle = .popover
            viewController.present(addWordVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Vocabularies VC
    
}
