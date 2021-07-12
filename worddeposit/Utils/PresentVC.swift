//
//  ShowLogin.swift
//  worddeposit
//
//  Created by Maksim Kalik on 9/19/20.
//  Copyright © 2020 Maksim Kalik. All rights reserved.
//

import UIKit

class PresentVC {
    // TODO: - Remove this shit!
    static var coordinator: MainCoordinator?
    
    // MARK: - Login VC
    static func loginVC(from view: UIView? = nil) {
        coordinator?.didLogout()
    }
    
    // MARK: - Add Word VC
    static func addWordVC(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: nil)
        if let addWordVC = storyboard.instantiateViewController(withIdentifier: Storyboards.AddWordVC) as? AddWordVC {
            addWordVC.modalPresentationStyle = .fullScreen
            viewController.present(addWordVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Vocabularies VC
    
}
