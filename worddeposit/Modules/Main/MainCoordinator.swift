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
    
    private var mainController: MainController?
    private var tabs: [UIViewController]? = [] {
        didSet {
            self.mainController?.setViewControllers(tabs, animated: true)
        }
    }
    
    init(navigationController: UINavigationController ) {
        self.navigationController = navigationController
    }

    deinit {
        print("deinit \(self)")
    }
    
    func start() {
        mainController = MainController()
        mainController?.viewModel = MainViewModel(coordinator: self)
        
        practices()
        addWord()
        
        guard let tabBarController = mainController else { return }
        navigationController.setViewControllers([tabBarController], animated: false)
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
        // TODO: Refactor it
        print("++++ MAIN / to vocabularies")
        let storyboard = UIStoryboard(name: Storyboards.Home, bundle: .main)
        guard let vocabulariesController = storyboard.instantiateViewController(withIdentifier: Controllers.Vocabularies) as? UINavigationController else { return }
        guard let vc = vocabulariesController.viewControllers.first as? VocabulariesTVC else { return }
        vc.coordinator = self
        vocabulariesController.modalPresentationStyle = .popover
        navigationController.present(vocabulariesController, animated: true)
    }
    
    func toAddWord() {
        mainController?.selectedIndex = 1
    }
    
    func toVocabulary() {
        print("++++ MAIN / to vocabulary")
    }
    
    func toProfile() {
        
    }
    
    // TODO: - take a look at this method
    func didLogout() {
        tabs = nil
        mainController = nil
        parentCoordinator?.childDidFinish(self)
        delegate?.coordinatorDidLogout(coordinator: self)
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

