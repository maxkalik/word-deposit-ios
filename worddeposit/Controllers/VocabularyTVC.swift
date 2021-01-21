import UIKit

class VocabularyTVC: SearchableTVC {
    
    // MARK: - Instances
    
    /// Data model for the table view
    var words = [Word]()
    var messageView = MessageView()
    var rightBarItem = TopBarItem()
    
    /// Search results table view
    private var resultsTableController: VocabularyResultsTVC!
    
    /// Flag for current vocabulary
    var isVocabularySwitched = false
    
    private var buttonNavTitleView = ButtonNavTitleView(type: .custom)
    private var progressHUD = ProgressHUD(title: "Fetching...")
    
    var vocabularyWordBubbleView: VocabularyWordBubbleView!

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Table View
        setupTableView()
        setupResultsTableController()
        setupNavigationBar()
        
        // Setup message
        view.addSubview(messageView)
        messageView.hide()
        setupMessage()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(vocabularySwitchBegan), name: NSNotification.Name(Keys.vocabulariesSwitchBeganNotificationKey), object: nil)
        nc.addObserver(self, selector: #selector(vocabularyDidSwitch), name: Notification.Name(Keys.vocabulariesSwitchNotificationKey), object: nil)
        nc.addObserver(self, selector: #selector(vocabularyDidUpdate), name: Notification.Name(Keys.currentVocabularyDidUpdateKey), object: nil)
        
        setupTitleView()
        vocabularyWordBubbleView = UINib(nibName: "VocabularyWordBubbleView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? VocabularyWordBubbleView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let superview = view.superview else { return }
        
        superview.addSubview(vocabularyWordBubbleView)
        
        if !progressHUD.isDescendant(of: superview) {
            view.superview?.addSubview(progressHUD)
            progressHUD.hide()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isVocabularySwitched == false {
            setupContent(words: UserService.shared.words) // <-- TODO: Bug
        }
        messageView.frame.origin.y = tableView.contentOffset.y
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        words.removeAll()
        tableView.reloadData()
        isVocabularySwitched = false
    }
    
    // MARK: - objc Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController{
            if let tvc = navigationController.topViewController as? VocabulariesTVC {
                tvc.delegate = self
            }
        }
    }
        
    @objc func vocabularyDidUpdate() {
        setupTitle()
    }
    
    @objc func vocabularySwitchBegan() {
        if !messageView.isHidden {
            messageView.isHidden = true
        }
        progressHUD.show()
    }
    
    @objc func vocabularyDidSwitch() {
        progressHUD.hide()
        words.removeAll()
        tableView.reloadData()
        setupContent(words: UserService.shared.words)
        isVocabularySwitched = true
    }
    
    // MARK: - View setups
    
    private func setupTitleView() {
        setupTitle()
        buttonNavTitleView.onPress {
            self.performSegue(withIdentifier: Segues.Vocabularies, sender: self)
        }
        navigationItem.titleView = buttonNavTitleView
    }
    
    private func setupTitle() {
        guard let vocabulary = UserService.shared.vocabulary else { return }
        buttonNavTitleView.setTitle(vocabulary.title, for: .normal)
        buttonNavTitleView.titleLabel?.addCharactersSpacing(spacing: -0.8, text: vocabulary.title)
    }
    
    private func setupNavigationBar() {
        // Right Bar Button Item
        rightBarItem.setIcon(name: Icons.Profile)
        rightBarItem.circled()
        rightBarItem.onPress {
            self.performSegue(withIdentifier: Segues.Profile, sender: self)
        }
        let rightBarButtonItem = UIBarButtonItem(customView: rightBarItem)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setupMessage() {
        messageView.setTitles(messageTxt: "You have no words yet", buttonTitle: "Add words")
        messageView.onPrimaryButtonTap { PresentVC.addWordVC(from: self) }
    }
    
    func setupTableView() {
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tableView.contentInset = insets
        
        let nib = UINib(nibName: XIBs.VocabularyTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: XIBs.VocabularyTVCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReusableIdentifiers.MessageView)
        navigationItem.title = ""
        tableView.backgroundColor = Colors.silver
    }
    
    func setupResultsTableController() {
        resultsTableController = self.storyboard?.instantiateViewController(withIdentifier: Storyboards.VocabularyResults) as? VocabularyResultsTVC
        resultsTableController.tableView.delegate = self
        resultsTableController.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self // Monitor when the search button is tapped
        
        // Place the search bar in the nav bar
        navigationItem.searchController = searchController

        // Make the search bar always visible
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Content
    
    private func setupContent(words: [Word]) {
        
        // Setup vocabulary title
        setupTitle()
        
        // Check words
        if words.isEmpty {
            messageView.show()
        } else {
            messageView.hide()
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
        vc.delegate = self
        vc.wordIndexPath = indexPath.row
        
        if tableView === self.tableView {
            vc.words = words
        } else {
            vc.words = resultsTableController.filteredWords
        }
        
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
            cell.backgroundColor = .clear
            cell.configureCell(word: words[indexPath.row])
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension VocabularyTVC: VocabularyTVCellDelegate {
    func vocabularyTVCellBeganLongPressed(with cellFrame: CGRect, and word: Word) {
        // print("vocabularyTVCellBeganLongPressed", cellFrame, word)
        vocabularyWordBubbleView.onPress()
    }
    
    func vocabularyTVCellDidFinishLognPress() {
        // print("vocabularyTVCellDidFinishLognPress")
        vocabularyWordBubbleView.onFinishPress()
    }
}

// MARK: - UITableViewCell Editing

extension VocabularyTVC {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let word: Word! = tableView === self.tableView ? words[indexPath.row] : resultsTableController.filteredWords[indexPath.row]
            
            UserService.shared.removeWord(word) { error in
                if error != nil {
                    self.simpleAlert(title: "Error", msg: "Sorry. Cannot remove word. Something wrong.")
                    return
                }
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

extension VocabularyTVC: VocabularyCardsVCDelegate {
    func wordCardDidUpdate(word: Word, index: Int) {
        wordDidUpdate(word, index: index)
    }
}

extension VocabularyTVC: VocabularyResultsTVCDelegate {
    func resultsWordDidRemove(word: Word) {
        guard let index = words.firstIndex(matching: word) else { return }
        self.wordDidRemove(word, index: index)
    }
}

extension VocabularyTVC: VocabulariesTVCDelegate {
    func onVocabulariesTVCDismiss() {
        self.buttonNavTitleView.initialState()
    }
}
