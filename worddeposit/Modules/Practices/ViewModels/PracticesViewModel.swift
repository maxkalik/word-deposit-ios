//
//  PracticesViewModel.swift
//  worddeposit
//
//  Created by Maksim Kalik on 7/13/21.
//  Copyright © 2021 Maksim Kalik. All rights reserved.
//

import Foundation

protocol PracticesViewModelDelegate: AnyObject {
    func allowInteractingWithUI(isInteract: Bool)
    func showError(_ msg: String)
    func startLoading()
    func finishLoading()
    func showDialogMessage(with title: String, buttonTitle: String)
    func hideDialogMessage()
    func finishSetupWords()
}

class PracticesViewModel {
    
    var words: [Word]?
    private var isVocabularySwitched = false
    private var coordinator: PracticesCoordinator
    weak var delegate: PracticesViewModelDelegate?

    init(coordinator: PracticesCoordinator) {
        self.coordinator = coordinator
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    var practices: [Practice] {
        return [
            Practice(
                title: "Find Correct Translation",
                coverImageSource: Images.trainerTranslateToWord,
                backgroundColor: Colors.lightPurple,
                type: .readWordToTranslate
            ),
            Practice(
                title: "Translate from your language",
                coverImageSource: Images.trainerWordToTranslate,
                backgroundColor: Colors.darkBlue,
                type: .readTranslateToWord
            )
        ]
    }
    
    var title: String {
        return "Practices"
    }
    
    var tabBarIcon: TabBarIcon {
        return .practices
    }
    
    func viewDidLoad() {
        getCurrentUser()
        NotificationCenter.default.addObserver(self, selector: #selector(vocabularyDidSwitch), name: Notification.Name(rawValue: Keys.vocabulariesSwitchNotificationKey), object: nil)
    }
    
    func viewWillAppear() {
        delegate?.startLoading()
    }
    
    func viewDidAppear() {
        if UserService.shared.vocabulary != nil && !isVocabularySwitched {
            setupWordsCollection(UserService.shared.words)
        }
    }

    @objc func vocabularyDidSwitch() {
        isVocabularySwitched = true
        setupWordsCollection(UserService.shared.words)
    }

    private func getCurrentUser() {
        print("==== get current user: \(UserService.shared.user?.id ?? "undefined")")
        if UserService.shared.user != nil {
            getWords()
        } else {
            fetchCurrentUser()
        }
    }
    
    private func showError(_ msg: String) {
        delegate?.finishLoading()
        delegate?.showError(msg)
    }
    
    private func fetchCurrentUser() {
        print("==== fetch current user")
        UserService.shared.fetchCurrentUser { [weak self] error, user in
            guard let self = self else { return }

            if let error = error {
                self.showError(error.localizedDescription)
//                self.coordinator.logOut()
            } else {
                guard let _ = user else {
                    self.showError("User not found")
//                    self.coordinator.logOut()
                    return
                }
                self.getWords()
            }
        }
    }
    
    private func getWords() {
        print("==== get words")
        UserService.shared.fetchVocabularies { [weak self] error, vocabularies in
            guard let self = self else { return }
            if let error = error {
                self.showError(error.message)
                return
            }
            guard let vocabularies = vocabularies else {
                self.showError("Unable to get info about vocabularies")
                return
            }
            
            if vocabularies.isEmpty {
                self.delegate?.finishLoading()
                self.coordinator.toVocabularies()
            } else {
                UserService.shared.getCurrentVocabulary()
                UserService.shared.fetchWords { error, words  in
                    if let error = error {
                        self.showError(error.message)
                        return
                    }
                    guard let words = words else {
                        self.showError("Unable get info about words")
                        return
                    }
                    self.setupWordsCollection(words)
                    self.delegate?.finishLoading()
                }
            }
        }
    }
    
    // TODO: - refactor this shit
    private func setupWordsCollection(_ words: [Word]) {
        print("==== setup words collection")
        self.words?.removeAll()
        self.words = words
        
        if words.count < Limits.minWordsAmount {
            // coordinator + assignV view model there with words count
            
            // TODO: MassageView viewModel
            let messageTitleTxt = "You have insufficient words amount for practice."
            let messageBtnTitle = "Add at least \(Limits.minWordsAmount - words.count) words"
            
            delegate?.showDialogMessage(with: messageTitleTxt, buttonTitle: messageBtnTitle)
        } else {
            delegate?.hideDialogMessage()
        }
        isVocabularySwitched = false
        self.delegate?.finishSetupWords()
    }
    
    func toVocabularies() {
        coordinator.toVocabularies()
    }
    
    func toAddWord() {
        coordinator.toAddWord()
    }
}

