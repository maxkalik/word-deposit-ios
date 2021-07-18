//
//  MainViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/18/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

class MainViewModel {
    
    private(set) var coordinator: MainCoordinator
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    
    func logout() {
        coordinator.didLogout()
    }
    
    func toProfile() {
        coordinator.toProfile()
    }
}
