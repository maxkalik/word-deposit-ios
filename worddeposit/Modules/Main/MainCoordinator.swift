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
    
    private var mainController: MainController
    private var tabs: [UIViewController]? = [] {
        didSet {
            self.mainController.setViewControllers(tabs, animated: true)
        }
    }
    
    init(navigationController: UINavigationController ) {
        self.navigationController = navigationController
        self.mainController = MainController()
    }

    deinit {
        print("dealloc \(self)")
    }
    
    func start() {
        practices()
        addWord()
        mainController.viewModel = MainViewModel(coordinator: self)
        navigationController.setViewControllers([mainController], animated: false)
    }
    
    private func practices() {
        let practicesViewController = PracticesViewController()
        let practicesCoordinator = PracticesCoordinator(navigationController: navigationController)
        practicesCoordinator.delegate = self
        let practicesViewModel = PracticesViewModel(coordinator: practicesCoordinator)
        practicesViewController.viewModel = practicesViewModel
        tabs?.append(practicesViewController)
    }
    
    private func addWord() {
        let addWord = TabTwoViewController()
        addWord.tabBarItem = UITabBarItem(title: "Add Word", image: UIImage(named: "icon_plus"), selectedImage: UIImage(named: "icon_plus"))
        tabs?.append(addWord)
    }
    
    private func vocabulary() {
        
    }

    func toVocabularies() {
        print("to vocabularies from main coordinator")
    }
    
    func toAddWord() {
        mainController.selectedIndex = 1
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
    func coordinatorDidTapToAddWord(coordinator: PracticesCoordinator) {
        toAddWord()
    }
    
    func coordinatorDidTapToVocabularies(coordinator: PracticesCoordinator) {
        toVocabularies()
    }
}

