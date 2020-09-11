import UIKit

class VocabularyTVC: UITableViewController {
    
    // MARK: - Instances
    
    /// Data model for the table view
    var words = [Word]()
    var messageView = MessageView()
    
    /// Search controller to help us with filtering items in the table view
    var searchController: UISearchController!
    
    /// Search results table view
    private var resultsTableController: VocabularyResultsTVC!
    
    /// Restoration state for UISearchController
    var restoredState = SearchControllerRestorableState()

    // var vocabulary: Vocabulary?

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Table View
        setupTableView()
         setupResultsTableController()
        
        // Setup message
        self.view.addSubview(messageView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(vocabularyDidSwitch), name: Notification.Name(rawValue: vocabulariesSwitchNotificationKey), object: nil)
    }
    
    @objc func vocabularyDidSwitch() {
        UserService.shared.fetchWords { words in
            self.words.removeAll()
            self.tableView.reloadData()
            self.prepareContent(words: words)
        }
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupMessage()
        messageView.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareContent(words: UserService.shared.words)
        messageView.frame.origin.y = tableView.contentOffset.y
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.isActive = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        words.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - View setups
    
    private func setupTitle() {
        guard let vocabulary = UserService.shared.currentVocabulary else { return }
        self.title = vocabulary.title
    }
    
    func setupMessage() {
        messageView.setTitles(messageTxt: "You have no words yet", buttonTitle: "Add words")
        messageView.onPrimaryButtonTap { self.tabBarController?.selectedIndex = 1 }
    }
    
    func setupTableView() {
        let nib = UINib(nibName: XIBs.VocabularyTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabularyTVCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReusableIdentifiers.MessageView)
    }
    
    func setupResultsTableController() {
        resultsTableController = self.storyboard?.instantiateViewController(withIdentifier: Storyboards.VocabularyResults) as? VocabularyResultsTVC
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        // searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.definesPresentationContext = true
        searchController.searchBar.delegate = self // Monitor when the search button is tapped
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Place the search bar in the nav bar
        navigationItem.searchController = searchController

        // Make the search bar always visible
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Content
    
    private func prepareContent(words: [Word]) {
        
        // Setup vocabulary title
        setupTitle()
        
        // Check words
        if words.isEmpty {
            self.messageView.show()
        } else {
            self.messageView.hide()
            for index in 0..<words.count {
                self.words.append(words[index])
                self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: .fade)
            }
        }
    }
    
    func wordDidUpdate(_ word: Word, index: Int) {
        self.words[index] = word
        tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .fade)
    }
    
    func wordDidRemove(_ word: Word, index: Int) {
        self.words.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .fade)
    }
}

// MARK: - UITableViewDelegate

extension VocabularyTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = VocabularyCardsVC()
        
        if tableView === self.tableView {
            vc.words = words
        } else {
            vc.words = resultsTableController.filteredWords
        }
        vc.wordIndexPath = indexPath.row
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
        // ?
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITableViewDataSource

extension VocabularyTVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: XIBs.VocabularyTVCell, for: indexPath) as? VocabularyTVCell {
            cell.configureCell(word: words[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewCell Editing

extension VocabularyTVC {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            // TODO: - not working when try to delete from searching state
            
            let word: Word! = tableView === self.tableView ? words[indexPath.row] : resultsTableController.filteredWords[indexPath.row]
            
            UserService.shared.removeWord(word) {
                self.wordDidRemove(word, index: indexPath.row)
            }
        }
    }
}


// MARK: - UISearchBarDelegate

extension VocabularyTVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
}
