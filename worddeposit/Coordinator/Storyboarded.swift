//
//  Storyboarded.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

protocol Storyboarded {
    static func instantiate(storyboard name: String) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(storyboard name: String) -> Self {
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(identifier: id) as! Self
    }
}
