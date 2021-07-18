//  Created by Maksim Kalik on 7/11/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.

import UIKit

protocol MainCoordinatorDelegate: AnyObject {
    func coordinatorDidLogout(coordinator: MainCoordinator)
}

class MainCoordinator: Coordinator {
    
    private(set) var childCoordinators = [Coordinator]()
    private(set) var navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    weak var delegate: MainCoordinatorDelegate?
    
    init(navigationController: UINavigationController ) {
        self.navigationController = navigationController
    }

    deinit {
        print("dealloc \(self)")
    }
    
    func start() {
        let mainController = MainController()
        mainController.viewModel = MainViewModel(coordinator: self)
        
        let practicesViewController = PracticesViewController()
        let practicesCoordinator = PracticesCoordinator(navigationController: navigationController)
        practicesCoordinator.delegate = self
        let practicesViewModel = PracticesViewModel(coordinator: practicesCoordinator)
        practicesViewController.viewModel = practicesViewModel
        let practicesTabBarItem = UITabBarItem(title: "Practices", image: UIImage(named: "icon_practice"), tag: 0)
        practicesViewController.tabBarItem = practicesTabBarItem

        
        let tabTwo = TabTwoViewController()
        let tabTwoBarItem = UITabBarItem(title: "Tab 2", image: UIImage(named: "icon_plus"), tag: 1)
        tabTwo.tabBarItem = tabTwoBarItem
        
        mainController.viewControllers = [practicesViewController, tabTwo]
        
//        navigationController.navigationBar.isHidden = true
//        navigationController.title = "Practice"
        
        navigationController.setViewControllers([mainController], animated: false)
    }
    
    func toVocabularies() {
        print("to vocabularies from main coordinator")
    }
    
    func toAddWords() {
        
    }
    
    func toVocabulary() {
        
    }
    
    func toProfile() {
        
    }
    
    // TODO: - take a look at this method
    func didLogout() {
        parentCoordinator?.childDidFinish(self)
        delegate?.coordinatorDidLogout(coordinator: self)
        
        // TODO: - maybe temporary solution
        navigationController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - didLogout called by MainViewModel
extension MainCoordinator: PracticesCoordinatorDelegate {
    func coordinatorDidSegueToVocabularies(coordinator: PracticesCoordinator) {
        toVocabularies()
    }
}

