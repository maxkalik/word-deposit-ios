//
//  PracticesCoordinator.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/14/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import UIKit

protocol PracticesCoordinatorDelegate: AnyObject {
    func coordinatorDidTapToVocabularies(coordinator: PracticesCoordinator)
    func coordinatorDidTapToAddWord(coordinator: PracticesCoordinator)
    
}

class PracticesCoordinator: Coordinator {
    
    private(set) var childCoordinators = [Coordinator]()
    private(set) var navigationController: UINavigationController
    weak var parentCoordinator: MainCoordinator?
    weak var delegate: PracticesCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("deinit - \(self)")
    }
    
    func start() {
        
    }
    
    func toVocabularies() {
        delegate?.coordinatorDidTapToVocabularies(coordinator: self)
    }
    
    func toAddWord() {
        delegate?.coordinatorDidTapToAddWord(coordinator: self)
    }
}
