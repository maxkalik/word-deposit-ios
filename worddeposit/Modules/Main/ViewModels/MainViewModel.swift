//
//  MainViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/18/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

protocol MainViewModelDelegate: AnyObject {
    func startLoading()
    func finishLoading()
    func showError(_ msg: String)
}

class MainViewModel {
    
    private(set) var coordinator: MainCoordinator
    weak var delegate: MainViewModelDelegate?
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    func logout() {
        delegate?.startLoading()
        UserService.shared.logout { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.showError(error.message)
                return
            }
            self.delegate?.finishLoading()
            self.coordinator.didLogout()
        }
    }
    
    func toProfile() {
        coordinator.toProfile()
    }
}
