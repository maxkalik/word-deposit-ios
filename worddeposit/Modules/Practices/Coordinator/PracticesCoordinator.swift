//
//  PracticesCoordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/14/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

protocol PracticesCoordinatorDelegate: AnyObject {
    func didLogout(coordinator: PracticesCoordinator)
}

class PracticesCoordinator: Coordinator {
    
    private(set) var childCoordinators = [Coordinator]()
    private(set) var navigationController: BaseNavigationController
    weak var parentCoordinator: AuthCoordinator?
    weak var delegate: PracticesCoordinatorDelegate?
    
    init(navigationController: BaseNavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("deinit - \(self)")
    }
    
    func start() {
        
    }
    
    func toVocabularies() {
        
    }
    
    func toAddWord() {
        
    }
    
    func logOut() {
        
    }
}
