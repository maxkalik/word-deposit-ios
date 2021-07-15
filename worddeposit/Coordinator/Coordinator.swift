//
//  Coordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/8/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: BaseNavigationController { get }
    var childCoordinators: [Coordinator] { get }
    func start()
}
